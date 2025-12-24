import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:foodmenu_admin/editmenu.dart';
import 'package:foodmenu_admin/main.dart';
import 'package:foodmenu_admin/menulist.dart';
import 'package:foodmenu_admin/payment.dart';
import 'package:foodmenu_admin/profile.dart';

class historyScreen extends StatefulWidget {
  @override
  _historyScreenState createState() => _historyScreenState();
}

class _historyScreenState extends State<historyScreen> {
  List<Map<dynamic, dynamic>> ordersfinallist = [];
  bool ishistorylistPageSelected = true;

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
              order.reversed.forEach((orderItem) {
                if (orderItem['is_order_confirmed']) {
                  orderItem['table'] = table;
                  //ordersfinallist.add(orderItem);
                  ordersfinallist.insert(0, orderItem);
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
          'Order history',
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
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_cart,
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
                  ishistorylistPageSelected = false;
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
                  ishistorylistPageSelected = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileEditPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.history,
                color: ishistorylistPageSelected ? Colors.red : null,
              ),
              onPressed: () {
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
                  ishistorylistPageSelected = false;
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

  OrderCard({required this.name, required this.quantity, required this.table});

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
                style: TextStyle(fontSize: 15.0),
              ),
              Text(
                '$quantity',
                style: const TextStyle(fontSize: 15.0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Flexible(
                    child:
                        SizedBox(), // Flexible to occupy the space between Quantity and Table
                  ),
                  Flexible(
                    child: Text(
                      table,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
