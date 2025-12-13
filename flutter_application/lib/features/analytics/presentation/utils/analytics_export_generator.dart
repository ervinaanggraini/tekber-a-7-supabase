import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../../domain/entities/analytics_summary.dart';
import '../../../reports/presentation/utils/report_export_helper.dart';

class AnalyticsExportGenerator {
  static Future<void> generateAndShareExcel(AnalyticsSummary summary, String periodLabel) async {
    final excel = Excel.createExcel();
    final String sheetName = excel.getDefaultSheet() ?? 'Sheet1';
    final Sheet sheet = excel[sheetName];

    sheet.appendRow(['Analisis Keuangan', periodLabel]);
    sheet.appendRow([]);
    sheet.appendRow(['Skor Kesehatan Keuangan', summary.financialHealthScore.toString()]);
    sheet.appendRow([]);

    // Monthly trends header
    sheet.appendRow(['Bulan', 'Pendapatan', 'Pengeluaran']);
    for (final t in summary.monthlyTrends) {
      sheet.appendRow([t.month, t.income.toString(), t.expense.toString()]);
    }
    sheet.appendRow([]);

    // Savings goal
    sheet.appendRow(['Target Tabungan', summary.savingsGoal.target.toString()]);
    sheet.appendRow(['Terkumpul', summary.savingsGoal.current.toString()]);
    sheet.appendRow(['Deadline', summary.savingsGoal.deadline]);
    sheet.appendRow([]);

    // Insights
    sheet.appendRow(['Wawasan', 'Tipe', 'Deskripsi']);
    for (final ins in summary.insights) {
      sheet.appendRow([ins.title, ins.type.toString().split('.').last, ins.description]);
    }

    final List<int>? bytes = excel.encode();
    if (bytes == null || bytes.isEmpty) throw Exception('Gagal membuat file Excel');

    final fileName = 'analisis_keuangan_${periodLabel.replaceAll(' ', '_')}.xlsx';
    await exportExcelBytes(Uint8List.fromList(bytes), fileName);
  }
}
