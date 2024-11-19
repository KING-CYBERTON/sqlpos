// ignore_for_file: public_member_api_docs, avoid_redundant_argument_values

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sqlpos/mysql.dart';

Future<void> main() async {
  runApp(const MyApp('Printing Demo'));
}

class MyApp extends StatelessWidget {
  const MyApp(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: 
        
        Center(
          child: ElevatedButton(
            onPressed: () async {


                              final dbHelper = MySQLHelper();
                  await dbHelper.openConnection();

                  List<Map<String, dynamic>> saleItems = [
                    {
                      'product_id': 1,
                      'quantity': 2,
                      'price': 50.00,
                      'total': 100.00
                    },
                    {
                      'product_id': 2,
                      'quantity': 1,
                      'price': 30.00,
                      'total': 30.00
                    },
                  ];

 

                  await dbHelper.execute(
                      ' INSERT INTO sales (sale_id,sale_date, customer_id, employee_id, total_amount, payment_method)  VALUES (126,NOW(), 1,2, 100.00, "cash")');
                  for (var item in saleItems) {
                    await dbHelper.execute(
                      '   INSERT INTO sales_items (sale_id, product_id, quantity, price, total) VALUES (126, ${item['product_id']}, ${item['quantity']},  ${item['price']}, ${item['total']})   ',
                    );
                  }

                  await dbHelper.closeConnection();
             // Get the list of available printers
              final printers = await Printing.listPrinters();

              // Check if printers are available and use the first printer as the default
              if (printers.isNotEmpty) {
                final defaultPrinter = printers.first;

                // Directly print to the default printer
                await Printing.directPrintPdf(
                  printer: defaultPrinter,
                  usePrinterSettings: true,
                  onLayout: (format) => _generatePdf(format, title),
                );
              } else {
                print('No printers available');
              }
            },
            child: const Text('Print Document'),
          ),
        ),

        //  PdfPreview(
        //   build: (format) => _generatePdf(format, title),
        // ),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, String title) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final font = await PdfGoogleFonts.nunitoExtraLight();



                  List<Map<String, dynamic>> saleItems = [
                    {
                      'product_id': 1,
                      'product_name': "flower",
                      'quantity': 2,
                      'price': 50.00,
                      'total': 100.00
                    },
                    {
                      'product_id': 2,
                      'product_name': "unga",
                      'quantity': 1,
                      'price': 30.00,
                      'total': 30.00
                    },
                  ];

  // List of items for the receipt
  List<Map<String, String>> items = [
    {'name': 'Lorem wheat', 'price': '1.50'},
    {'name': 'Ipsum apple', 'price': '3.75'},
    {'name': 'Dolor banana', 'price': '7.30'},
    {'name': 'Sit meat', 'price': '9.50'},
    {'name': 'Amet candy', 'price': '0.80'},
    {'name': 'Consectetur coffee', 'price': '1.20'},
  ];

  // Receipt totals
  double taxable = 20.45;
  double vat = 3.60;
  double total = 24.05;
  double cash = 25.00;
  double change = 0.95;

  pdf.addPage(
    pw.Page(
      pageFormat: format,
      build: (context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(16.0),
          width: 300,
          color: PdfColors.white,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('SHOP RECEIPT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('SUPERMARKET 123'),
                    pw.Text('PLANET EARTH'),
                    pw.Text('Tel: +123-456-7890'),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Text('RECEIPT #: 12345'),
              pw.Text('DATE: 12/12/2023'),
              pw.Text('CASHIER: PRIYAL SUMARIA'),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // Top row header for item description and price
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('ITEM DESCRIPTION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('PRICE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.Divider(),

              // Loop through the items and create rows
              ...saleItems.map(
                (item) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(item['product_name']!),
                      pw.Text(item['price'].toString()!),
                    ],
                  ),
                ),
              ).toList(),

              pw.Divider(),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TAXABLE'),
                    pw.Text(taxable.toStringAsFixed(2)),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('VAT 15%'),
                    pw.Text(vat.toStringAsFixed(2)),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(total.toStringAsFixed(2)),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('CASH'),
                    pw.Text(cash.toStringAsFixed(2)),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('CHANGE'),
                    pw.Text(change.toStringAsFixed(2)),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Paid with CASH'),
              pw.Divider(),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('THANK YOU', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('HAVE A NICE DAY'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );





    // pdf.addPage(
    //   pw.Page(
    //     pageFormat: format,
    //     build: (context) {
    //       return pw.Column(
    //         children: [
    //           pw.SizedBox(
    //             width: double.infinity,
    //             child: pw.FittedBox(
    //               child: pw.Text(title, style: pw.TextStyle(font: font)),
    //             ),
    //           ),
    //           pw.SizedBox(height: 20),
    //           pw.Flexible(child: pw.FlutterLogo()),
    //         ],
    //       );
    //     },
    //   ),
    // );

    return pdf.save();
  }


}
