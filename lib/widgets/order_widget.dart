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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            'Ordered At: ${order.createdAt}',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          SizedBox(height: 5),
          Text(
            'Status: ${order.state}',
            style: TextStyle(fontSize: 14, color: Colors.blueAccent),
          ),
          SizedBox(height: 10),
          ...order.items.map((item) => Text(
                '${item.quantity}x ${item.name}',
                style: TextStyle(fontSize: 14),
              )),
        ],
      ),
    );
  }
}
