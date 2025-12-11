import 'dart:io';
import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import '../../domain/entities/report_summary.dart';

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
      sheet.appendRow([name, c.amount.toString(), '${c.percentage.toStringAsFixed(1)}%']);
    }

    // Encode to bytes
    final List<int>? fileBytes = excel.encode();
    if (fileBytes == null || fileBytes.isEmpty) {
      throw Exception('Failed to generate Excel file');
    }

    final tempDir = await getTemporaryDirectory();
    final fileName = 'laporan_keuangan_${periodLabel.replaceAll(' ', '_')}.xlsx';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(fileBytes, flush: true);

    // Share file
    await Share.shareXFiles([XFile(file.path)], text: 'Laporan Keuangan - $periodLabel');
  }
}
