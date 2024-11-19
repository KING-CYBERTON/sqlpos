import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReceiptGenerator {
  Future<void> generateAndPrintReceipt() async {
    final pdf = pw.Document();

    // Build the receipt PDF content
    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text('Receipt', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Store: Flutter Shop', style: pw.TextStyle(fontSize: 18)),
            pw.Text('Date: ${DateTime.now().toLocal().toString()}', style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Item', 'Price', 'Quantity', 'Total'],
              data: [
                ['Item 1', '\$10.00', '2', '\$20.00'],
                ['Item 2', '\$15.00', '1', '\$15.00'],
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('Total: \$35.00', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ],
        );
      },
    ));

    // Open the print dialog to allow printing the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
