import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/data/transaction_datasource.dart';

enum TransactionType { deposit, withdrawal }

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

// UBAH: Fungsi ini sekarang menangani List<Map<String, dynamic>>
Future<bool> showAndProcessAddTransactionDialog(
  BuildContext context, {
  TransactionType initialType = TransactionType.withdrawal,
}) async {
  final TransactionDataSource transactionDataSource =
      TransactionDataSourceImpl();

  // UBAH: Tipe data yang diharapkan dari dialog adalah List<Map<String, dynamic>>
  final List<Map<String, dynamic>>? transactionDataList =
      await showDialog<List<Map<String, dynamic>>?>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return _AddTransactionDialog(initialType: initialType);
        },
      );

  if (!context.mounted) return false;

  print('📤 Hasil dari dialog: $transactionDataList');

  // UBAH: Periksa apakah list tidak null dan tidak kosong
  if (transactionDataList != null && transactionDataList.isNotEmpty) {
    try {
      print('📡 Mengirim data ke API...');
      print('📦 Payload: $transactionDataList');

      // UBAH: Kirim seluruh list ke data source
      // CATATAN: Pastikan `createTransaction` di-update untuk menerima List
      await transactionDataSource.createTransaction(transactionDataList);

      print('✅ Transaksi berhasil dikirim!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil ditambahkan!'),
          backgroundColor: AppColors.success,
        ),
      );
      return true;
    } on DioException catch (e) {
      print('❌ DioException terjadi');
      print('📨 Pesan: ${e.message}');
      print('📡 Status: ${e.response?.statusCode}');
      print('📦 Response: ${e.response?.data}');

      String errorMessage = 'Koneksi bermasalah';
      if (e.response?.data != null &&
          e.response!.data is Map<String, dynamic>) {
        errorMessage =
            e.response!.data['message'] ?? 'Terjadi kesalahan pada server.';
      } else if (e.response?.statusCode == 308) {
        errorMessage =
            'Kesalahan konfigurasi: Mohon hubungi developer (Error 308).';
      } else if (e.response?.data is String &&
          (e.response!.data as String).isNotEmpty) {
        errorMessage = 'Gagal memproses. Server merespon dengan kesalahan.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: $errorMessage'),
          backgroundColor: AppColors.danger,
        ),
      );
      return false;
    } catch (e) {
      print('🛑 Exception tidak diketahui: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan tidak terduga: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
      return false;
    }
  } else {
    print("⚠️ Transaksi dibatalkan oleh pengguna atau kosong.");
    return false;
  }
}

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

  // UBAH: Logika utama pembuatan payload diubah di sini
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final transactionTypeString =
          _selectedType == TransactionType.deposit ? 'deposit' : 'withdrawal';

      // Buat List<Map> sesuai format yang diminta
      final List<Map<String, dynamic>> payload =
          _items.map((item) {
            final double price =
                double.tryParse(
                  item.priceController.text.replaceAll('.', ''),
                ) ??
                0.0;

            // Setiap item menjadi objek transaksi terpisah
            return {
              "description": item.descriptionController.text,
              "transaction_type": transactionTypeString,
              "amount": 1, // Sesuai format baru
              "total_price": price, // Gunakan 'total_price' bukan 'price'
            };
          }).toList();

      print('📥 Form valid. Data transaksi akan dikirim: $payload');
      // Kirim seluruh list sebagai hasil dari dialog
      Navigator.of(context).pop(payload);
    } else {
      print('⚠️ Form tidak valid!');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (Sisa dari widget build tidak perlu diubah) ...
    // Kode widget build Anda dari sini ke bawah sudah benar.
    // Cukup salin bagian yang telah diubah di atas.
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
    // ... (Metode ini tidak perlu diubah) ...
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
