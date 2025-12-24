import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:foodmenu_admin/main.dart';
import 'package:pdf/pdf.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class QRListWidget extends StatelessWidget {
  final List<String> itemList;

  QRListWidget({required this.itemList});
  Future<List<Uint8List>> generateQrCodes(List<String> items) async {
    List<Uint8List> qrCodes = [];
    for (var item in items) {
      final qrPainter = QrPainter(
        data: item,
        version: QrVersions.auto,
      );
      final image = await qrPainter.toImage(200);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      qrCodes.add(byteData!.buffer.asUint8List());
    }
    return qrCodes;
  }

  Future<void> _saveAsPdf(BuildContext context) async {
    final pdf = pw.Document();

    // Assuming generateQrCodes returns a List<List<int>> representing QR code bytes
    final qrCodes = await generateQrCodes(itemList);

    for (var qrCode in qrCodes) {
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          String pageNum = context.pageNumber.toString();
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Table $pageNum',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Scan QR Code:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Image(pw.MemoryImage(qrCode)),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Instruction',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Scan QR Code: Open the app, scan the hotel QR code.'),
                pw.SizedBox(height: 5.00),
                pw.Text('Add Items: Tap the "+" next to what you want.'),
                pw.SizedBox(height: 5.00),
                pw.Text('Confirm Order: Go to "Order", check, and confirm.'),
                pw.SizedBox(height: 5.00),
                pw.Text('Enjoy Your Meal: Relax, your order will come soon!'),
              ],
            ),
          );
        },
      ));
    }
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('QR code downloaded Successfully'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'QR Code Generation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: itemList.length,
              itemBuilder: (context, index) {
                String item = itemList[index];
                return ListTile(
                  title: Text(item),
                  subtitle: QrImageView(
                    data: item,
                    version: QrVersions.auto,
                    size: 100,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _saveAsPdf(context),
              child: const Text(
                'Save as PDF',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
