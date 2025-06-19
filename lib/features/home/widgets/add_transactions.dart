// file: add_transaction_dialog.dart (atau nama file UI dialog Anda)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart'; // <-- Tambahkan impor untuk DioException

// Impor yang dibutuhkan dari proyek Anda
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/data/transaction_datasource.dart';

enum TransactionType { deposit, withdrawal }

// --- Model TransactionItem (TETAP SAMA, TIDAK ADA PERUBAHAN) ---
class TransactionItem {
  final TextEditingController descriptionController;
  final TextEditingController priceController;

  TransactionItem()
    : descriptionController = TextEditingController(),
      priceController = TextEditingController();

  void dispose() {
    descriptionController.dispose();
    priceController.dispose();
  }
}

// --- FUNGSI UTAMA BARU UNTUK MENAMPILKAN DAN MEMPROSES DIALOG ---
// Nama fungsi diubah agar lebih deskriptif
// Fungsi ini sekarang mengembalikan Future<bool> yang menandakan keberhasilan.
Future<bool> showAndProcessAddTransactionDialog(
  BuildContext context, {
  TransactionType initialType = TransactionType.withdrawal,
}) async {
  // 1. Buat instance dari TransactionDataSource di sini
  final TransactionDataSource transactionDataSource =
      TransactionDataSourceImpl();

  // 2. Tampilkan dialog dan tunggu hasilnya (data transaksi atau null)
  final Map<String, dynamic>? transactionData =
      await showDialog<Map<String, dynamic>?>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          // Dialog widget internal tidak diubah
          return _AddTransactionDialog(initialType: initialType);
        },
      );

  // Pastikan widget masih ada di tree (best practice untuk async-await)
  if (!context.mounted) return false;

  // 3. Proses hasil dari dialog
  if (transactionData != null) {
    // Tampilkan loading indicator jika diperlukan (misal dengan dialog lain)
    // atau biarkan user menunggu sebentar.

    try {
      // 4. Kirim data ke API menggunakan data source
      await transactionDataSource.createTransaction(transactionData);

      // 5. Tampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil ditambahkan!'),
          backgroundColor: AppColors.success,
        ),
      );
      return true; // Kembalikan true jika sukses
    } on DioException catch (e) {
      // Tangani error spesifik dari Dio/API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal: ${e.response?.data['message'] ?? 'Koneksi bermasalah'}',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return false; // Kembalikan false jika gagal
    } catch (e) {
      // Tangani error umum lainnya
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan tidak terduga: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
      return false; // Kembalikan false jika gagal
    }
  } else {
    // Pengguna menekan "Batal" atau menutup dialog
    print("Penambahan transaksi dibatalkan oleh pengguna.");
    return false; // Kembalikan false karena tidak ada transaksi yang dibuat
  }
}

// --- WIDGET DIALOG (_AddTransactionDialog) ---
// Bagian ini sebagian besar tetap sama.
// Perubahan hanya pada fungsi _submitForm untuk HANYA mengembalikan data.

class _AddTransactionDialog extends StatefulWidget {
  final TransactionType initialType;
  const _AddTransactionDialog({required this.initialType});

  @override
  State<_AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<_AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  late List<TransactionItem> _items;
  late TransactionType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _items = [TransactionItem()];
  }

  @override
  void dispose() {
    for (var item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(TransactionItem());
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items[index].dispose();
        _items.removeAt(index);
      });
    }
  }

  // FUNGSI SUBMIT FORM SEKARANG HANYA MENGEMBALIKAN DATA, TIDAK LEBIH
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final transactionTypeString =
          _selectedType == TransactionType.deposit ? 'deposit' : 'withdrawal';

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

      final double totalPrice = itemsData.fold(
        0,
        (sum, item) => sum + (item['price'] as double),
      );

      final result = {
        "transaction_type": transactionTypeString,
        "items": itemsData,
        "total_price": totalPrice,
      };

      // Kembalikan map 'result' ke pemanggil showDialog (yaitu fungsi showAndProcessAddTransactionDialog)
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- UI TIDAK ADA PERUBAHAN ---
    // (Kode build widget Anda yang sudah ada diletakkan di sini,
    // tidak perlu diubah sama sekali)
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
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return _buildItemInput(index);
                  },
                ),
              ),
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

  Widget _buildItemInput(int index) {
    // --- UI TIDAK ADA PERUBAHAN ---
    // (Kode build item input Anda yang sudah ada diletakkan di sini)
    final item = _items[index];
    final bool canRemove = _items.length > 1;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

// Class Formatter Mata Uang (TETAP SAMA, TIDAK ADA PERUBAHAN)
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
