import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/core/constants/app_colors.dart';
import 'package:flutter_application/core/widgets/skeleton_loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_application/features/transactions/domain/entities/category.dart';
import 'package:flutter_application/features/transactions/presentation/cubit/add_transaction_cubit.dart';
import 'package:intl/intl.dart';

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedType = 'expense'; // 'income' or 'expense'
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load categories based on initial type
    context.read<AddTransactionCubit>().loadCategories(type: _selectedType);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _changeType(String type) {
    if (_selectedType != type) {
      setState(() {
        _selectedType = type;
        _selectedCategory = null; // Reset category when type changes
      });
      context.read<AddTransactionCubit>().loadCategories(type: type);
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
        );
        return;
      }

      final authState = context.read<AuthBloc>().state;
      if (authState is AuthUserAuthenticated) {
        context.read<AddTransactionCubit>().createTransaction(
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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isDark ? null : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.pink.shade50.withOpacity(0.3),
            ],
          ),
          color: isDark ? null : null,
        ),
        padding: const EdgeInsets.all(20),
        child: BlocListener<AddTransactionCubit, AddTransactionState>(
          listener: (context, state) {
            if (state is AddTransactionCreated) {
              Navigator.of(context).pop(true); // Return true to indicate success
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaksi berhasil ditambahkan')),
              );
            } else if (state is AddTransactionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            }
          },
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppColors.linier,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_card, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Tambah Transaksi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),                  // Type Toggle
                  Row(
                    children: [
                      Expanded(
                        child: _TypeButton(
                          label: 'Pengeluaran',
                          isSelected: _selectedType == 'expense',
                          onTap: () => _changeType('expense'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TypeButton(
                          label: 'Pemasukan',
                          isSelected: _selectedType == 'income',
                          onTap: () => _changeType('income'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Category Dropdown
                  BlocBuilder<AddTransactionCubit, AddTransactionState>(
                    builder: (context, state) {
                      if (state is AddTransactionCategoriesLoaded) {
                        return _CustomDropdown(
                          value: _selectedCategory,
                          label: 'Kategori',
                          icon: Icons.category_outlined,
                          items: state.categories,
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        );
                      } else if (state is AddTransactionLoading) {
                        return _SkeletonDropdown();
                      }
                      return const SizedBox();
                    },
                  ),
                  const SizedBox(height: 12),

                  // Description Field
                  _CustomTextField(
                    controller: _descriptionController,
                    label: 'Deskripsi Barang',
                    icon: Icons.description_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan deskripsi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Amount Field
                  _CustomTextField(
                    controller: _amountController,
                    label: 'Harga Barang',
                    icon: Icons.payments_outlined,
                    prefixText: 'Rp ',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan harga';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Harga harus lebih dari 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Date Picker
                  _CustomDateField(
                    selectedDate: _selectedDate,
                    onTap: _selectDate,
                  ),
                  const SizedBox(height: 16),

                  // Buttons
                  BlocBuilder<AddTransactionCubit, AddTransactionState>(
                    builder: (context, state) {
                      final isCreating = state is AddTransactionCreating;
                      return Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isCreating ? null : () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isCreating ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                shadowColor: AppColors.b93160.withOpacity(0.4),
                                backgroundColor: AppColors.b93160,
                                foregroundColor: Colors.white,
                              ),
                              child: isCreating
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Simpan'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.linier : null,
          color: isSelected ? null : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.pink.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

// Custom TextField with gradient focus and icon
class _CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? prefixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.prefixText,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  State<_CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<_CustomTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: _isFocused ? AppColors.linier : null,
        border: _isFocused ? null : Border.all(color: Colors.grey.shade300),
      ),
      padding: _isFocused ? const EdgeInsets.all(2) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(_isFocused ? 10 : 12),
        ),
        child: Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            validator: widget.validator,
            decoration: InputDecoration(
              labelText: widget.label,
              prefixText: widget.prefixText,
              prefixIcon: Icon(
                widget.icon,
                color: _isFocused ? AppColors.b93160 : Colors.grey,
                size: 20,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_isFocused ? 10 : 12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Dropdown with gradient and icon
class _CustomDropdown extends StatefulWidget {
  final Category? value;
  final String label;
  final IconData icon;
  final List<Category> items;
  final void Function(Category?) onChanged;

  const _CustomDropdown({
    required this.value,
    required this.label,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  @override
  State<_CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<_CustomDropdown> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: _isFocused ? AppColors.linier : null,
        border: _isFocused ? null : Border.all(color: Colors.grey.shade300),
      ),
      padding: _isFocused ? const EdgeInsets.all(2) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(_isFocused ? 10 : 12),
        ),
        child: Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: DropdownButtonFormField<Category>(
            value: widget.value,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: widget.label,
              prefixIcon: Icon(
                widget.icon,
                color: _isFocused ? AppColors.b93160 : Colors.grey,
                size: 20,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_isFocused ? 10 : 12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: widget.items.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(
                  category.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }).toList(),
            onChanged: widget.onChanged,
            validator: (value) {
              if (value == null) {
                return 'Pilih kategori';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}

// Custom Date Field with gradient and icon
class _CustomDateField extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const _CustomDateField({
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd MMM yyyy').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// Skeleton Loader for Dropdown
class _SkeletonDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          SkeletonCircle(size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(height: 10, width: 60),
                const SizedBox(height: 4),
                SkeletonLine(height: 14, width: double.infinity),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
