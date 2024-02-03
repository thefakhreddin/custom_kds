import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/square_service.dart'; // Adjust the import path as needed
import '../widgets/order_widget.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Order>> ordersFuture;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchLatestOrders();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _fetchLatestOrders();
    });
  }

  void _fetchLatestOrders() {
    // Assuming you have a method to fetch orders from the current day
    ordersFuture = SquareService().fetchOrdersFromToday();
    setState(() {}); // Trigger a rebuild with the new orders
  }

  @override
  void dispose() {
    _timer.cancel(); // Always cancel a timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... (other scaffold properties if any)
      body: FutureBuilder<List<Order>>(
        future: ordersFuture, // This is the Future your UI depends on
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No orders found'));
            }

            // Here is where you replace the existing GridView.custom builder
            return GridView.custom(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              childrenDelegate: SliverChildBuilderDelegate(
                (context, index) {
                  final order = snapshot.data![index];
                  final double cardWidth =
                      MediaQuery.of(context).size.width / 2 -
                          16; // For two-column grid layout
                  return OrderWidget(order: order, width: cardWidth);
                },
                childCount: snapshot.data!.length,
              ),
            );
          } else {
            // Show a loading spinner while the orders are being fetched
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
