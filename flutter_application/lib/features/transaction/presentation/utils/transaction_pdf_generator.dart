import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/entities/transaction.dart';
import 'package:intl/intl.dart';

class TransactionPdfGenerator {
  static Future<void> generateAndSharePdf(
    List<Transaction> transactions,
    DateTime start,
    DateTime end,
    String periodLabel,
  ) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) {
          final dateFormat = DateFormat('yyyy-MM-dd');
          final timeFormat = DateFormat('HH:mm');

          return [
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.pink300,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Riwayat Transaksi', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                  pw.SizedBox(height: 6),
                  pw.Text('Periode: $periodLabel', style: pw.TextStyle(fontSize: 12, color: PdfColors.white)),
                ],
              ),
            ),
            pw.SizedBox(height: 12),
            if (transactions.isEmpty)
              pw.Text('Tidak ada transaksi untuk periode ini')
            else
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headers: ['Tanggal', 'Waktu', 'Tipe', 'Kategori', 'Deskripsi', 'Jumlah'],
                data: transactions.map((tx) {
                  return [
                    dateFormat.format(tx.date),
                    timeFormat.format(tx.date),
                    tx.type,
                    tx.categoryName,
                    tx.description,
                    tx.amount.toStringAsFixed(0),
                  ];
                }).toList(),
              ),
            pw.Spacer(),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Text('Dibuat pada: ${DateTime.now().toString().split('.')[0]}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'riwayat_transaksi_$periodLabel.pdf',
    );
  }
}
