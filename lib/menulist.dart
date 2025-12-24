import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:foodmenu_admin/editmenu.dart';
import 'package:foodmenu_admin/history.dart';
import 'package:foodmenu_admin/main.dart';
import 'package:foodmenu_admin/payment.dart';
import 'package:foodmenu_admin/profile.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<Map<dynamic, dynamic>> ordersfinallist = [];
  bool isorderlistPageSelected = true;

  @override
  void initState() {
    super.initState();
    temporderlist();
  }

  orderdata() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("FoodMenu/Order");
    Stream<DatabaseEvent> stream = ref.onValue;

    await stream.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        var ordersData = event.snapshot.value as Map<dynamic, dynamic>;
        ordersfinallist = [];
        ordersData.forEach((key, value) {
          var hotel = value['hotel'];
          var order = value['order'];
          var table = value['table'];
          if (hotel == emailid) {
            setState(() {
              order.forEach((orderItem) {
                if (!orderItem['is_order_confirmed']) {
                  orderItem['table'] = table;
                  orderItem['Key'] = key;
                  ordersfinallist.add(orderItem);
                }
              });
            });
          }
        });
      }
    });
  }

  temporderlist() async {
    await orderdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Order Confirmation',
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
      body: ordersfinallist.isEmpty
          ? const Center(
              child: Text(
                "No orders to display",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ListView.builder(
              itemCount: ordersfinallist.length,
              itemBuilder: (context, index) {
                return OrderCard(
                  name: ordersfinallist[index]['name'],
                  quantity: ordersfinallist[index]['quantity'],
                  table: ordersfinallist[index]['table'],
                  index: index,
                  keys: ordersfinallist[index]['Key'],
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.shopping_cart,
                color: isorderlistPageSelected ? Colors.red : null,
              ),
              onPressed: () {
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
                  isorderlistPageSelected = false;
                });
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
                  isorderlistPageSelected = false;
                });
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
                  isorderlistPageSelected = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => historyScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.payment,
              ),
              onPressed: () {
                setState(() {
                  isorderlistPageSelected = false;
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

class OrderCard extends StatelessWidget {
  final String name;
  final int quantity;
  final String table;
  final int index;
  final String keys;
  OrderCard(
      {required this.name,
      required this.quantity,
      required this.table,
      required this.index,
      required this.keys});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 4.0),
            const Text(
              'Quantity:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Text(
              '$quantity',
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Text(
              table,
              style:
                  const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.cancel,
                color: Colors.red,
                size: 50.0,
              ),
              onPressed: () async {
                DatabaseReference ref =
                    FirebaseDatabase.instance.ref("FoodMenu/Order/$keys");
                DatabaseEvent event = await ref.once();
                var ordersDataevent =
                    event.snapshot.value as Map<dynamic, dynamic>;

                var hotel = ordersDataevent['hotel'];
                var order = ordersDataevent['order'];
                if (hotel == emailid) {
                  if (order[index]['name'] == name &&
                      order[index]['quantity'] == quantity &&
                      order[index]['is_order_confirmed'] != true) {
                    order[index]['is_order_confirmed'] = true;
                    order.removeAt(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            const Text('Order has been removed successfully'),
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
                  } else {
                    for (var i = 0; i < order.length; i++) {
                      if (order[i]['name'] == name &&
                          order[i]['quantity'] == quantity &&
                          order[i]['is_order_confirmed'] != true) {
                        order[i]['is_order_confirmed'] = true;
                        order.removeAt(i);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Order has been removed successfully'),
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
                        break;
                      }
                    }
                  }
                }
                await ref.update({"order": order});
              },
            ),
            const SizedBox(width: 25.0),
            IconButton(
              icon: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 50.0,
              ),
              onPressed: () async {
                DatabaseReference ref =
                    FirebaseDatabase.instance.ref("FoodMenu/Order/$keys");
                DatabaseEvent event = await ref.once();
                var ordersDataevent =
                    event.snapshot.value as Map<dynamic, dynamic>;

                var hotel = ordersDataevent['hotel'];
                var order = ordersDataevent['order'];
                if (hotel == emailid) {
                  if (order[index]['name'] == name &&
                      order[index]['quantity'] == quantity &&
                      order[index]['is_order_confirmed'] == false) {
                    order[index]['is_order_confirmed'] = true;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Order has been updated'),
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
                  } else {
                    for (var i = 0; i < order.length; i++) {
                      if (order[i]['name'] == name &&
                          order[i]['quantity'] == quantity &&
                          order[i]['is_order_confirmed'] == false) {
                        order[i]['is_order_confirmed'] = true;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Order has been updated'),
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
                        break;
                      }
                    }
                  }
                }
                await ref.update({"order": order});
              },
            ),
          ],
        ),
      ),
    );
  }
}
