import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacings.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../../../../dependency_injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../transactions/domain/entities/category.dart';
import '../../../transactions/presentation/cubit/add_transaction_cubit.dart';
import '../../../transactions/domain/use_cases/update_transaction_use_case.dart';
import '../../domain/entities/transaction.dart' as simple_tx;

class AddTransactionPage extends StatefulWidget {
  final simple_tx.Transaction? transaction; // null = add mode, non-null = edit mode

  const AddTransactionPage({
    super.key,
    this.transaction,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  late String _selectedType;
  Category? _selectedCategory;
  late DateTime _selectedDate;
  late AddTransactionCubit _cubit;

  bool get isEditMode => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<AddTransactionCubit>();

    if (isEditMode) {
      final t = widget.transaction!;
      _selectedType = t.type;
      _selectedDate = t.date;
      _descriptionController.text = t.description;
      _amountController.text = t.amount.toInt().toString();
      _notesController.text = '';
      // Will need to load category from categoryId
      _cubit.loadCategories(type: t.type);
      // Find and set category after categories are loaded
      _cubit.stream.listen((state) {
        if (state is AddTransactionCategoriesLoaded && _selectedCategory == null) {
          final category = state.categories.firstWhere(
            (c) => c.id == t.categoryId,
            orElse: () => state.categories.first,
          );
          setState(() {
            _selectedCategory = category;
          });
        }
      });
    } else {
      _selectedType = 'expense';
      _selectedDate = DateTime.now();
    }

    _cubit.loadCategories(type: _selectedType);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _changeType(String type) {
    if (_selectedType != type) {
      setState(() {
        _selectedType = type;
        _selectedCategory = null;
      });
      _cubit.loadCategories(type: type);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
        );
        return;
      }

      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthUserAuthenticated) return;

      if (isEditMode) {
        // Update existing transaction
        final updateUseCase = getIt<UpdateTransactionUseCase>();
        try {
          await updateUseCase.execute(
            UpdateTransactionParams(
              transactionId: widget.transaction!.id,
              userId: authState.user.id,
              category: _selectedCategory!,
              type: _selectedType,
              amount: double.parse(_amountController.text),
              description: _descriptionController.text,
              notes: _notesController.text.isEmpty ? null : _notesController.text,
              transactionDate: _selectedDate,
              inputMethod: 'manual',
              createdAt: widget.transaction!.createdAt,
            ),
          );
          if (mounted) {
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaksi berhasil diperbarui')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        }
      } else {
        // Create new transaction
        _cubit.createTransaction(
          userId: authState.user.id,
          category: _selectedCategory!,
          type: _selectedType,
          amount: double.parse(_amountController.text),
          description: _descriptionController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          transactionDate: _selectedDate,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            isEditMode ? 'Edit Transaksi' : 'Tambah Transaksi',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.pink[200] : AppColors.b93160,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.pink[200] : AppColors.b93160),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocListener<AddTransactionCubit, AddTransactionState>(
          listener: (context, state) {
            if (state is AddTransactionCreated) {
              Navigator.of(context).pop(true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaksi berhasil ditambahkan')),
              );
            } else if (state is AddTransactionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.s16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Type Toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTypeButton('Pengeluaran', 'expense', isDark),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTypeButton('Pemasukan', 'income', isDark),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Category Dropdown
                  BlocBuilder<AddTransactionCubit, AddTransactionState>(
                    builder: (context, state) {
                      if (state is AddTransactionCategoriesLoaded) {
                        return _buildCategoryDropdown(state.categories, isDark);
                      } else if (state is AddTransactionLoading) {
                        return _buildSkeletonDropdown(isDark);
                      }
                      return const SizedBox();
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Description Field
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Deskripsi',
                    icon: Icons.description_outlined,
                    isDark: isDark,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan deskripsi';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Amount Field
                  _buildTextField(
                    controller: _amountController,
                    label: 'Jumlah',
                    icon: Icons.payments_outlined,
                    prefixText: 'Rp ',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    isDark: isDark,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan jumlah';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Jumlah harus lebih dari 0';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Notes Field
                  _buildTextField(
                    controller: _notesController,
                    label: 'Catatan (opsional)',
                    icon: Icons.note_outlined,
                    isDark: isDark,
                    maxLines: 3,
                  ),
                  SizedBox(height: 16.h),

                  // Date Picker
                  _buildDateField(isDark),
                  SizedBox(height: 24.h),

                  // Submit Button
                  BlocBuilder<AddTransactionCubit, AddTransactionState>(
                    builder: (context, state) {
                      final isLoading = state is AddTransactionCreating;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.b93160,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                isEditMode ? 'Perbarui' : 'Simpan',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, String value, bool isDark) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () => _changeType(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.b93160 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(List<Category> categories, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<Category>(
        value: _selectedCategory,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Kategori',
          labelStyle: GoogleFonts.poppins(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          prefixIcon: Icon(
            Icons.category_outlined,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          border: InputBorder.none,
        ),
        dropdownColor: isDark ? Colors.grey[850] : Colors.white,
        style: GoogleFonts.poppins(
          color: isDark ? Colors.white : Colors.black87,
        ),
        items: categories.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(
              category.name,
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Pilih kategori';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    String? prefixText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        maxLines: maxLines,
        style: GoogleFonts.poppins(
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          prefixText: prefixText,
          prefixStyle: GoogleFonts.poppins(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          prefixIcon: Icon(
            icon,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDateField(bool isDark) {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(_selectedDate),
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SkeletonCircle(size: 20.sp),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(height: 10.h, width: 60.w),
                const SizedBox(height: 4),
                SkeletonLine(height: 14.h, width: double.infinity),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
