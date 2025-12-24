import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodmenu_admin/menulist.dart';
import 'package:foodmenu_admin/qrcode.dart';

List qrcodelist = [];
var admindetails;
String emailid = '';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyBHHp246xp0x4MbJPUlo4BTeD-ATl1GvCU",
    authDomain: "foodadmin-32e2a.firebaseapp.com",
    projectId: "foodadmin-32e2a",
    storageBucket: "foodadmin-32e2a.firebasestorage.app",
    messagingSenderId: "340399575765",
    appId: "1:340399575765:web:7d269793be566e5de8085c",
    databaseURL: "https://foodadmin-32e2a-default-rtdb.firebaseio.com/",));
    runApp(MyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

String _generateID(String email) {
  // String combinedInfo = '$name$address$phoneNumber';
  // var bytes = utf8.encode(combinedInfo);
  // var hash = sha256.convert(bytes);
  // String id = hash.toString().substring(0, 10);
  // return id;
  List<String> parts = email.split('@');
  return parts.first;
}

generateqrcodedata(id, numberoftable) {
  for (var i = 1; i <= numberoftable; i++) {
    qrcodelist
        .add('https://foodadmin-32e2a.web.app?hotel=$emailid&table=Table$i');
  }
}

signuppagewithemailandpasswd(
    name, emailid, passwd, address, phonenum, menu, numberoftable, id) async {
  // ignore: unused_local_variable
  UserCredential userCredential = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: emailid, password: passwd);
  DatabaseReference ref = FirebaseDatabase.instance.ref("FoodMenu/Admin");
  var admindetails = {
    'name': name,
    'emailid': emailid,
    'password': passwd,
    'phonenumber': phonenum,
    'address': address,
    'menu': menu,
    'numberoftable': numberoftable
  };
  DatabaseReference newOrderRef = ref.child(id);
  await newOrderRef.set(admindetails);
}

Future<bool> resetpassword(emailid, BuildContext context) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: emailid);
    return true;
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.code),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
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
  return false;
}

Future<bool> signinpagewithemailandpasswd(
    emailid, passwd, BuildContext context) async {
  try {
    // ignore: unused_local_variable
    UserCredential userCredential1 = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: emailid, password: passwd);
    return true;
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.code),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
    return false;
  }
}

Future<void> fetchData() async {
  DatabaseReference ref =
      FirebaseDatabase.instance.ref("FoodMenu/Admin/$emailid");
  DatabaseEvent event = await ref.once();
  var data = event.snapshot.value;
  admindetails = [];
  admindetails = data;
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Choicy\'s view admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.red,
      ),
      home: LoginPage(),
    );
  }
}

// ignore: use_key_in_widget_constructors
class LoginPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                'asset/favicon.png',
                width: 100,
                height: 100,
              ),
            ),
            // const SizedBox(height: 10),
            // const Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 24.0),
            //   child: Text(
            //     'Welcome back!',
            //     style: TextStyle(
            //       fontSize: 28,
            //       color: Colors.red,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (await signinpagewithemailandpasswd(_emailController.text,
                      _passwordController.text, context)) {
                    emailid = _generateID(_emailController.text);
                    await fetchData();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderScreen(),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.red,
                ),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account?'),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Forgetted the password?'),
                  const SizedBox(width: 5),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgetPasswordPage()),
                      );
                    },
                    child: const Text(
                      'Reset Password',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: use_key_in_widget_constructors

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reenterpasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _numberOfTablesController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _menuCategories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'asset/favicon.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Join Choicy\'s view',
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
                  controller: _emailController,
                  validator: (value) {
                    if (_emailController.text.isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(_emailController.text)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
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
                  controller: _passwordController,
                  validator: (value) {
                    if (_passwordController.text.isEmpty) {
                      return 'Password is required';
                    }
                    if (!RegExp(
                            r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$')
                        .hasMatch(_passwordController.text)) {
                      return 'Password must contain at least 8 characters, including upper and lower case letters, numbers, and special characters';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                  controller: _reenterpasswordController,
                  validator: (value) {
                    if (_reenterpasswordController.text.isEmpty) {
                      return 'Password is required';
                    }
                    if (!RegExp(
                            r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$')
                        .hasMatch(_reenterpasswordController.text)) {
                      return 'Password must contain at least 8 characters, including upper and lower case letters, numbers, and special characters';
                    }
                    if (_reenterpasswordController.text !=
                        _passwordController.text) {
                      return 'Reenter password should match with the password.';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Reenter Password',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Menu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        for (int categoryIndex = 0;
                            categoryIndex < _menuCategories.length;
                            categoryIndex++)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Category: ${_menuCategories[categoryIndex]['category']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        _menuCategories.removeAt(categoryIndex);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              for (int itemIndex = 0;
                                  itemIndex <
                                      _menuCategories[categoryIndex]['items']
                                          .length;
                                  itemIndex++)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: TextFormField(
                                          initialValue:
                                              _menuCategories[categoryIndex]
                                                  ['items'][itemIndex]['item'],
                                          decoration: InputDecoration(
                                            labelText: 'Item',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              _menuCategories[categoryIndex]
                                                      ['items'][itemIndex]
                                                  ['item'] = value;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          initialValue:
                                              _menuCategories[categoryIndex]
                                                          ['items'][itemIndex]
                                                      ['price']
                                                  .toString(),
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: 'Price',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              _menuCategories[categoryIndex]
                                                          ['items'][itemIndex]
                                                      ['price'] =
                                                  int.tryParse(value);
                                            });
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          setState(() {
                                            _menuCategories[categoryIndex]
                                                    ['items']
                                                .removeAt(itemIndex);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _menuCategories[categoryIndex]['items']
                                        .add({'item': '', 'price': 0});
                                  });
                                },
                                child: const Text('Add Item'),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                TextEditingController _categoryController =
                                    TextEditingController();
                                return AlertDialog(
                                  title: const Text('Add Category'),
                                  content: TextFormField(
                                    controller: _categoryController,
                                    decoration: const InputDecoration(
                                      labelText: 'Category Name',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _menuCategories.add({
                                            'category':
                                                _categoryController.text,
                                            'items': []
                                          });
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Add'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text('Add Category'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
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
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      var id = _generateID(_emailController.text);
                      emailid = id;
                      await signuppagewithemailandpasswd(
                          _nameController.text,
                          _emailController.text,
                          _passwordController.text,
                          _addressController.text,
                          _phoneNumberController.text,
                          _menuCategories,
                          _numberOfTablesController.text,
                          id);
                      await generateqrcodedata(
                          id, int.parse(_numberOfTablesController.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Sign up successfully'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          action: SnackBarAction(
                            label: 'Close',
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            },
                          ),
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRListWidget(
                            itemList: qrcodelist.cast<String>(),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.red,
                  ),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: use_key_in_widget_constructors
class ForgetPasswordPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final GlobalKey<FormState> _formKeyforget = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forget Password',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKeyforget,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (_emailController.text.isEmpty ||
                        !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(_emailController.text)) {
                      return 'Enter a valid email!';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKeyforget.currentState!.validate()) {
                      if (await resetpassword(_emailController.text, context)) {
                        Fluttertoast.showToast(
                          msg: "Password reset email sent!",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                        );
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.red,
                  ),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: const Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
