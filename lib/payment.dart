import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:foodmenu_admin/editmenu.dart';
import 'package:foodmenu_admin/history.dart';
import 'package:foodmenu_admin/main.dart';
import 'package:foodmenu_admin/menulist.dart';
import 'package:foodmenu_admin/profile.dart';

class PaymentDetails extends StatefulWidget {
  @override
  _PaymentDetailsState createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  bool isPaymentListPageSelected = true;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Payment Confirmation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
        ),
        body: ItemList(),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart
                ),
                onPressed: () {
                  setState(() {
                    isPaymentListPageSelected = false;
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
                    isPaymentListPageSelected = false;
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
                    isPaymentListPageSelected = false;
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
                    isPaymentListPageSelected = false;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => historyScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.payment),
                color: isPaymentListPageSelected ? Colors.red : null,
                onPressed: () {
                  setState(() {
                    isPaymentListPageSelected = true;
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
      ),
    );
  }
}

class ItemList extends StatefulWidget {
  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  List<Map<String, dynamic>> paymentlist = [];

  @override
  void initState() {
    super.initState();
    tempfunction();
  }

  tempfunction() async {
    await paymentdata();
  }

  paymentdata() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("FoodMenu/Payment");
    Stream<DatabaseEvent> stream = ref.onValue;

    stream.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        var ordersData = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          paymentlist = [];
          ordersData.forEach((key, value) {
            var hotel = value['hotel'];
            var order = value['amount'];
            var table = value['table'];
            if (hotel == emailid) {
              var orderItem = <String, dynamic>{};
              orderItem['table'] = table;
              orderItem['amount'] = double.tryParse(order.toString()) ?? 0.0;
              orderItem['Key'] = key;
              paymentlist.add(orderItem);
            }
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return paymentlist.isEmpty
        ? const Center(
            child: Text(
              "No orders to display",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: paymentlist.length,
            itemBuilder: (context, index) {
              return TableItem(
                keydata: paymentlist[index]['Key'].toString(),
                tableNumber: paymentlist[index]['table'].toString(),
                amount: paymentlist[index]['amount'],
                onPaid: () {
                  setState(() {
                    paymentlist.removeAt(index);
                  });
                },
              );
            },
          );
  }
}

class TableItem extends StatefulWidget {
  final String tableNumber;
  final double amount;
  final String keydata;
  final VoidCallback onPaid;

  const TableItem({
    Key? key,
    required this.tableNumber,
    required this.amount,
    required this.keydata,
    required this.onPaid,
  }) : super(key: key);

  @override
  _TableItemState createState() => _TableItemState();
}

class _TableItemState extends State<TableItem> {
  bool isPaid = false;

  void markAsPaid() async {
    setState(() {
      isPaid = true;
    });

    var keydata = widget.keydata;
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("FoodMenu/Payment/$keydata");

    await ref.remove().then((_) {
      widget.onPaid();
      print(
          'Table ${widget.tableNumber} marked as paid and removed from Firebase');
    }).catchError((error) {
      setState(() {
        isPaid = false;
      });
      print('Failed to mark as paid: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${widget.tableNumber}\n',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: 'Amount \$${widget.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 53, 52, 52),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: isPaid ? null : markAsPaid,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            child: const Text('Paid'),
          ),
        ],
      ),
    );
  }
}
