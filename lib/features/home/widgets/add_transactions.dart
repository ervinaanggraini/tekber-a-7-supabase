import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // <-- Impor ScreenUtil
import 'package:intl/intl.dart';
import 'package:moneyvesto/core/constants/color.dart';

enum TransactionType { deposit, withdrawal }

// Model untuk merepresentasikan satu item/barang
class TransactionItem {
  final TextEditingController descriptionController;
  final TextEditingController priceController;

  TransactionItem()
    : descriptionController = TextEditingController(),
      priceController = TextEditingController();

  // Fungsi untuk membuang controller saat tidak lagi digunakan
  void dispose() {
    descriptionController.dispose();
    priceController.dispose();
  }
}

// --- FUNGSI UTAMA UNTUK MENAMPILKAN DIALOG ---
Future<Map<String, dynamic>?> showAddTransactionDialog(
  BuildContext context, {
  TransactionType initialType = TransactionType.withdrawal,
}) {
  return showDialog<Map<String, dynamic>?>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return _AddTransactionDialog(initialType: initialType);
    },
  );
}

class _AddTransactionDialog extends StatefulWidget {
  final TransactionType initialType;
  const _AddTransactionDialog({required this.initialType});

  @override
  State<_AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<_AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();

  // Mengelola daftar item transaksi
  late List<TransactionItem> _items;
  late TransactionType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    // Mulai dengan satu item kosong saat dialog dibuka
    _items = [TransactionItem()];
  }

  @override
  void dispose() {
    // Pastikan semua controller di dalam _items dibuang
    for (var item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  // --- FUNGSI UNTUK MENGELOLA ITEM ---
  void _addItem() {
    setState(() {
      _items.add(TransactionItem());
    });
  }

  void _removeItem(int index) {
    // Jangan hapus item terakhir
    if (_items.length > 1) {
      setState(() {
        // Buang controller sebelum menghapus dari daftar
        _items[index].dispose();
        _items.removeAt(index);
      });
    }
  }

  // --- FUNGSI UNTUK SUBMIT FORM ---
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final transactionTypeString =
          _selectedType == TransactionType.deposit ? 'deposit' : 'withdrawal';

      // Kumpulkan data dari setiap item
      final List<Map<String, dynamic>> itemsData =
          _items.map((item) {
            return {
              "description": item.descriptionController.text,
              "price":
                  double.tryParse(
                    item.priceController.text.replaceAll('.', ''),
                  ) ??
                  0,
            };
          }).toList();

      // Hitung total harga dari semua item
      final double totalPrice = itemsData.fold(
        0,
        (sum, item) => sum + (item['price'] as double),
      );

      final result = {
        "transaction_type": transactionTypeString,
        "items": itemsData,
        "total_price": totalPrice,
      };

      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan warna dari AppColors
    final activeColor =
        _selectedType == TransactionType.deposit
            ? AppColors.success
            : AppColors.danger;

    return AlertDialog(
      backgroundColor: AppColors.secondaryAccent,
      title: Text(
        'Tambah Transaksi Baru',
        style: TextStyle(color: AppColors.textLight, fontSize: 20.sp),
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          // Gunakan .w untuk lebar agar responsif
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Tombol Segmented untuk Tipe Transaksi ---
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.withdrawal,
                    label: Text('Pengeluaran'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: TransactionType.deposit,
                    label: Text('Pemasukan'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
                style: SegmentedButton.styleFrom(
                  backgroundColor: AppColors.background,
                  selectedBackgroundColor: activeColor.withOpacity(0.2),
                  selectedForegroundColor: activeColor,
                  foregroundColor: AppColors.inactiveIndicator,
                ),
              ),
              SizedBox(height: 24.h),

              // --- Daftar Isian Barang (Dinamis) ---
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return _buildItemInput(index);
                  },
                ),
              ),

              // --- Tombol Tambah Item ---
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: const Text('Tambah Barang'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Batal',
            style: TextStyle(color: AppColors.textLight),
          ),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: activeColor,
            foregroundColor: AppColors.textLight,
          ),
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  // Widget untuk satu baris isian item
  Widget _buildItemInput(int index) {
    final item = _items[index];
    final bool canRemove = _items.length > 1;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Form Deskripsi Barang ---
          Expanded(
            flex: 5,
            child: TextFormField(
              controller: item.descriptionController,
              style: const TextStyle(color: AppColors.textLight),
              decoration: InputDecoration(
                labelText: 'Deskripsi Barang ${index + 1}',
                labelStyle: const TextStyle(color: AppColors.inactiveIndicator),
                hintText: 'Contoh: Beras 5kg',
                hintStyle: const TextStyle(color: AppColors.inactiveIndicator),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(
                  Icons.description_outlined,
                  color: AppColors.inactiveIndicator,
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.inactiveIndicator),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryAccent),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Wajib diisi';
                }
                return null;
              },
            ),
          ),
          SizedBox(width: 12.w),
          // --- Form Harga Barang ---
          Expanded(
            flex: 4,
            child: TextFormField(
              controller: item.priceController,
              style: const TextStyle(color: AppColors.textLight),
              decoration: InputDecoration(
                labelText: 'Harga',
                labelStyle: const TextStyle(color: AppColors.inactiveIndicator),
                prefixText: 'Rp ',
                prefixStyle: const TextStyle(color: AppColors.textLight),
                border: const OutlineInputBorder(),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.inactiveIndicator),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryAccent),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _CurrencyInputFormatter(),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Wajib diisi';
                }
                return null;
              },
            ),
          ),
          // --- Tombol Hapus Item ---
          if (canRemove)
            Padding(
              padding: EdgeInsets.only(left: 8.w, top: 4.h),
              child: IconButton(
                icon: const Icon(Icons.remove_circle, color: AppColors.danger),
                onPressed: () => _removeItem(index),
              ),
            ),
        ],
      ),
    );
  }
}

// Class Formatter Mata Uang (Tetap Sama)
class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    if (newValue.text.isEmpty) {
      return newValue;
    }
    final int value = int.parse(newValue.text);
    final formatter = NumberFormat.decimalPattern('id_ID');
    final newText = formatter.format(value);
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
