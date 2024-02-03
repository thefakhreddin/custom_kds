import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/square_service.dart';
import '../widgets/order_widget.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Order> _orders = []; // Manage orders directly
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchLatestOrders();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      // Reduced for more frequent updates
      _fetchLatestOrders();
    });
  }

  void _fetchLatestOrders() async {
    try {
      var newOrders = await SquareService().fetchOrdersFromToday();
      updateOrders(newOrders);
    } catch (e) {
      // Handle any errors here
      print('Failed to fetch orders: $e');
    }
  }

  void updateOrders(List<Order> newOrders) {
    setState(() {
      // This is a simple way to update orders without complex logic for adding/removing/updating individual items.
      // For more efficient updates, consider comparing newOrders with _orders and applying only necessary changes.
      _orders = newOrders;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _orders.isEmpty
          ? Center(child: Text('No orders found'))
          : GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                final double cardWidth =
                    MediaQuery.of(context).size.width / 2 - 16;
                return OrderWidget(
                    key: ValueKey(order.id), order: order, width: cardWidth);
              },
            ),
    );
  }
}
