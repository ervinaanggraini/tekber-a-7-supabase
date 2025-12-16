import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../../domain/entities/transaction.dart';
import '../../../reports/presentation/utils/report_export_helper.dart';
import 'package:intl/intl.dart';

class TransactionExportGenerator {
  static Future<void> generateAndShareExcel(
      List<Transaction> transactions,
      DateTime start,
      DateTime end,
      String periodLabel) async {
    final excel = Excel.createExcel();
    final String sheetName = excel.getDefaultSheet() ?? 'Sheet1';
    final Sheet sheet = excel[sheetName];

    // Header
    sheet.appendRow(['Riwayat Transaksi', periodLabel]);
    sheet.appendRow([]);

    // Table header
    sheet.appendRow(['Tanggal', 'Waktu', 'Tipe', 'Kategori', 'Deskripsi', 'Jumlah']);

    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');

    for (final tx in transactions) {
      sheet.appendRow([
        dateFormat.format(tx.date),
        timeFormat.format(tx.date),
        tx.type,
        tx.categoryName,
        tx.description,
        tx.amount.toString(),
      ]);
    }

    final List<int>? fileBytes = excel.encode();
    if (fileBytes == null || fileBytes.isEmpty) {
      throw Exception('Gagal membuat file Excel');
    }

    final fileName = 'riwayat_transaksi_${periodLabel.replaceAll(' ', '_')}.xlsx';
    final bytes = Uint8List.fromList(fileBytes);
    await exportExcelBytes(bytes, fileName);
  }
}
