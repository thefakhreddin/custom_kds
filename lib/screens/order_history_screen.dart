import 'package:flutter/material.dart';
import '../widgets/order_widget.dart'; // Adjust the import path as needed
import '../models/order.dart'; // Adjust the import path as needed

class OrderHistoryScreen extends StatelessWidget {
  final List<Order> orders = []; // Placeholder for orders list

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // Ensuring the background is black for consistency
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return OrderWidget(
              order: orders[index], width: MediaQuery.of(context).size.width);
        },
      ),
    );
  }
}
