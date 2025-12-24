import 'dart:typed_data';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:foodmenu_admin/editmenu.dart';
import 'package:foodmenu_admin/history.dart';
import 'package:foodmenu_admin/menulist.dart';
import 'package:foodmenu_admin/payment.dart';
import './main.dart';
import 'package:pdf/pdf.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ProfileEditPage extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

List<String> qrcodelist = [];
generateqrcodedata(tablecount) {
  qrcodelist = [];
  for (var i = 1; i <= int.parse(tablecount); i++) {
    qrcodelist
        .add('https://foodmenu-bb86e.web.app?hotel=$emailid&table=Table$i');
  }
}

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
  final qrCodes = await generateQrCodes(qrcodelist);
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

class _ProfileEditPageState extends State<ProfileEditPage> {
  final TextEditingController _nameController = TextEditingController();
  //final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _numberOfTablesController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isprofilePageSelected = true;
  @override
  void initState() {
    super.initState();
    _nameController.text = admindetails['name'];
    // _emailController.text = admindetails['emailid'];
    _phoneNumberController.text = admindetails['phonenumber'];
    _addressController.text = admindetails['address'];
    _numberOfTablesController.text = admindetails['numberoftable'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (_nameController.text.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextFormField(
                  controller: _addressController,
                  validator: (value) {
                    if (_addressController.text.isEmpty) {
                      return 'Address is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextFormField(
                  controller: _phoneNumberController,
                  validator: (value) {
                    if (_phoneNumberController.text.isEmpty) {
                      return 'Phone Number is required';
                    }
                    if (!RegExp(r'^[0-9]{10}$')
                        .hasMatch(_phoneNumberController.text)) {
                      return 'Enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextFormField(
                  controller: _numberOfTablesController,
                  validator: (value) {
                    if (_numberOfTablesController.text.isEmpty) {
                      return 'Number of Tables is required';
                    }
                    if (int.tryParse(_numberOfTablesController.text) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Number of Tables',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: () async {
            await generateqrcodedata(_numberOfTablesController.text);
            _saveAsPdf(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text(
            'Download QR code',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            DatabaseReference ref =
                FirebaseDatabase.instance.ref("FoodMenu/Admin/$emailid");
            await ref.update({
              "name": _nameController.text,
              "phonenumber": _phoneNumberController.text,
              "address": _addressController.text,
              "numberoftable": _numberOfTablesController.text,
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Profile changes saved successfully'),
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
          },
          child: const Text(
            'Save Changes',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                setState(() {
                  isprofilePageSelected = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                setState(() {
                  isprofilePageSelected = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Editmenu()),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: isprofilePageSelected ? Colors.red : null,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileEditPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.history,
              ),
              onPressed: () {
                setState(() {
                  isprofilePageSelected = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => historyScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.payment),
              onPressed: () {
                setState(() {
                  isprofilePageSelected = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentDetails()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
