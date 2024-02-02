import 'package:flutter/material.dart';
import '../models/order.dart';
import '../widgets/order_widget.dart';

class HomeScreen extends StatelessWidget {
  // Mock list of orders for testing
  final List<Order> orders = [
    Order(id: '1', description: '2x Pizza, 1x Soda'),
    Order(id: '2', description: '1x Burger, 2x Fries'),
    // Add more orders here as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GridView.custom(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200, // Maximum extent of each grid item
          childAspectRatio: 3 / 4, // Aspect ratio of each grid card
          crossAxisSpacing: 8, // Horizontal space between cards
          mainAxisSpacing: 8, // Vertical space between cards
        ),
        childrenDelegate: SliverChildBuilderDelegate(
          (context, index) => OrderWidget(order: orders[index]),
          childCount: orders.length,
        ),
      ),
    );
  }
}
