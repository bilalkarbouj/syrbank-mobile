import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReceiptService {
  static Future<Uint8List> generate({
    required String receiverAccount,
    required String amount,
    required String description,
    required String senderName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "TRANSFER DEKONTU",
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(),

                pw.SizedBox(height: 16),
                _row("Gönderen", senderName),
                _row("Alıcı Hesap No", receiverAccount),
                _row("Tutar", "$amount ₺"),
                _row("Açıklama", description.isEmpty ? "-" : description),
                _row("Tarih", DateTime.now().toString().substring(0, 19)),

                pw.Spacer(),

                pw.Divider(),
                pw.Text(
                  "Bu dekont bilgilendirme amaçlıdır.",
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _row(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(value),
        ],
      ),
    );
  }
}
