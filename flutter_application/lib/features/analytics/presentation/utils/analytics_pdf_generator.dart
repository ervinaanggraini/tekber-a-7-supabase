import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/entities/analytics_summary.dart';

class AnalyticsPdfGenerator {
  static Future<void> generateAndSharePdf(AnalyticsSummary summary, String periodLabel) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.pink300,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Analisis Keuangan', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    pw.SizedBox(height: 5),
                    pw.Text('Periode: $periodLabel', style: const pw.TextStyle(fontSize: 14, color: PdfColors.white)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Skor Kesehatan: ${summary.financialHealthScore}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              pw.Text('Tren Bulanan', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Table(border: pw.TableBorder.all(color: PdfColors.grey300), children: [
                pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.grey200), children: [
                  _cell('Bulan', true), _cell('Pendapatan', true), _cell('Pengeluaran', true),
                ]),
                ...summary.monthlyTrends.map((t) => pw.TableRow(children: [ _cell(t.month), _cell(t.income.toString()), _cell(t.expense.toString()) ])).toList(),
              ]),
              pw.SizedBox(height: 12),
              pw.Text('Target Tabungan', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text('Target: ${summary.savingsGoal.target}, Terkumpul: ${summary.savingsGoal.current}, Deadline: ${summary.savingsGoal.deadline}'),
              pw.SizedBox(height: 12),
              pw.Text('Wawasan', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              ...summary.insights.map((ins) => pw.Container(padding: const pw.EdgeInsets.only(bottom: 8), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [ pw.Text(ins.title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)), pw.Text(ins.description, style: pw.TextStyle(fontSize: 12)) ]))),
              pw.Spacer(),
              pw.Divider(),
              pw.SizedBox(height: 6),
              pw.Text('Dibuat pada: ${DateTime.now().toString().split('.')[0]}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'analisis_keuangan_$periodLabel.pdf');
  }

  static pw.Widget _cell(String content, [bool header = false]) => pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(content, style: pw.TextStyle(fontSize: header ? 12 : 10, fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal)));
}
