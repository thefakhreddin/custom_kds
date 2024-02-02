import 'package:flutter/material.dart';
import '../models/order.dart';

class OrderWidget extends StatelessWidget {
  final Order order;

  const OrderWidget({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order ID: ${order.id}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier', // Monospaced font for the ID, optional
            ),
          ),
          SizedBox(height: 10),
          Text(
            order.description,
            style: TextStyle(
              fontSize: 14,
              fontFamily:
                  'Courier', // Monospaced font for the description, optional
            ),
          ),
          // Add more details here as needed
        ],
      ),
    );
  }
}
