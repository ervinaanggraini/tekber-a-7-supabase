import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../../domain/entities/report_summary.dart';
import 'report_export_helper.dart';

class ReportExportGenerator {
  /// Generate a real .xlsx file from [summary] and share it.
  static Future<void> generateAndShareExcel(ReportSummary summary, String periodLabel) async {
    final excel = Excel.createExcel();

    // Use default sheet
    final String sheetName = excel.getDefaultSheet() ?? 'Sheet1';
    final Sheet sheet = excel[sheetName];

    // Header
    sheet.appendRow(['Laporan Keuangan', periodLabel]);
    sheet.appendRow([]);

    // Summary
    sheet.appendRow(['Total Pemasukan', summary.totalIncome.toString()]);
    sheet.appendRow(['Total Pengeluaran', summary.totalExpense.toString()]);
    sheet.appendRow(['Saldo Akhir', summary.balance.toString()]);
    sheet.appendRow([]);

    // Table header
    sheet.appendRow(['Kategori', 'Jumlah', 'Persentase']);

    final categories = summary.categoryBreakdown.values
      .where((c) => c.amount > 0)
      .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    for (final c in categories) {
      final name = c.categoryName;
      sheet.appendRow([name, c.amount.toString(), '${c.percentage}%']);
    }

    // Encode to bytes
    final List<int>? fileBytes = excel.encode();
    if (fileBytes == null || fileBytes.isEmpty) {
      throw Exception('Failed to generate Excel file');
    }

    final fileName = 'laporan_keuangan_${periodLabel.replaceAll(' ', '_')}.xlsx';
    final bytes = Uint8List.fromList(fileBytes);
    await exportExcelBytes(bytes, fileName);
  }
}
