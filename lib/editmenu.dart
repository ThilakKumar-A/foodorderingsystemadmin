import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:foodmenu_admin/history.dart';
import 'package:foodmenu_admin/menulist.dart';
import 'package:foodmenu_admin/payment.dart';
import 'package:foodmenu_admin/profile.dart';
import './main.dart';

// ignore: use_key_in_widget_constructors
class Editmenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Choicy\'s view admin',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: EditableListScreen(),
    );
  }
}

List<Map<String, dynamic>> items = [];

class EditableListScreen extends StatefulWidget {
  @override
  _EditableListScreenState createState() => _EditableListScreenState();
}

class _EditableListScreenState extends State<EditableListScreen> {
  bool iseditmenuPageSelected = true;
  @override
  void initState() {
    super.initState();
    listToMap();
  }

  listToMap() {
    items = [];
    if (admindetails['menu'] != null && admindetails['menu'] is List) {
      for (var item in admindetails['menu']) {
        if (item.containsKey('category') && item.containsKey('items')) {
          var category = item['category'] as String;
          var itemList = item['items'] as List;

          var formattedItems = itemList.map((subItem) {
            return {
              'item': subItem['item'] as String,
              'price': subItem['price'] as int,
            };
          }).toList();

          items.add({
            'category': category,
            'items': formattedItems,
          });
        }
      }
    }
  }

  void editItem(String category, int index) {
    Map<String, dynamic> item =
        items.firstWhere((cat) => cat['category'] == category)['items'][index];

    TextEditingController itemNameController =
        TextEditingController(text: item['item']);
    TextEditingController itemPriceController =
        TextEditingController(text: item['price'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemNameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: itemPriceController,
                decoration: const InputDecoration(labelText: 'Item Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  items.firstWhere(
                          (cat) => cat['category'] == category)['items'][index]
                      ['item'] = itemNameController.text;
                  items.firstWhere(
                          (cat) => cat['category'] == category)['items'][index]
                      ['price'] = int.parse(itemPriceController.text);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void removeItem(String category, int index) {
    setState(() {
      items
          .firstWhere((cat) => cat['category'] == category)['items']
          .removeAt(index);
    });
  }

  void editCategory(String oldCategory) {
    TextEditingController categoryController =
        TextEditingController(text: oldCategory);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  items.firstWhere(
                          (cat) => cat['category'] == oldCategory)['category'] =
                      categoryController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void addCategory() {
    TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  items.add({
                    'category': categoryController.text,
                    'items': [],
                  });
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void addItem(String category) {
    TextEditingController itemNameController = TextEditingController();
    TextEditingController itemPriceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemNameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: itemPriceController,
                decoration: const InputDecoration(labelText: 'Item Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  var categoryIndex =
                      items.indexWhere((cat) => cat['category'] == category);
                  if (categoryIndex != -1) {
                    items[categoryIndex]['items'].add({
                      'item': itemNameController.text,
                      'price': int.parse(itemPriceController.text),
                    });
                  } else {
                    items.add({
                      'category': category,
                      'items': [
                        {
                          'item': itemNameController.text,
                          'price': int.parse(itemPriceController.text),
                        }
                      ],
                    });
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menu',
          style: TextStyle(
            fontSize: 18,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Column(
                children: [
                  for (var category in items)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Category: ${category['category']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                editCategory(category['category']);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (var item in category['items'])
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    initialValue: item['item'],
                                    decoration: InputDecoration(
                                      labelText: 'Item',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      item['item'] = value;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    initialValue: item['price'].toString(),
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Price',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      item['price'] = int.tryParse(value) ?? 0;
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    setState(() {
                                      category['items'].remove(item);
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
                              category['items'].add({'item': '', 'price': 0});
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
                                    items.add({
                                      'category': _categoryController.text,
                                      'items': [],
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
      ),
      persistentFooterButtons: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            DatabaseReference ref =
                FirebaseDatabase.instance.ref("FoodMenu/Admin/$emailid");
            await ref.update({
              "menu": items,
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Edited Menu saved successfully'),
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
                  iseditmenuPageSelected = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.menu,
                color: iseditmenuPageSelected ? Colors.red : null,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Editmenu()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                setState(() {
                  iseditmenuPageSelected = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileEditPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                setState(() {
                  iseditmenuPageSelected = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentDetails()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.payment),
              onPressed: () {
                setState(() {
                  iseditmenuPageSelected = false;
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
