import 'package:flutter/material.dart';
import '../models/order.dart';
import 'package:intl/intl.dart';

class OrderWidget extends StatelessWidget {
  final Order order;
  final double width;

  const OrderWidget({
    Key? key,
    required this.order,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemsString =
        order.items.map((item) => '${item.quantity}x ${item.name}').join('\n');

    final dateTime = DateTime.parse(order.createdAt).toLocal();
    final formattedTime = DateFormat('hh:mm a').format(dateTime);

    return Container(
      width: width,
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white, // Background color of the whole card
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize:
            MainAxisSize.min, // Allows the card to grow to fit the content
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors
                  .grey[850], // Slightly lighter than black for the header
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              formattedTime,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            // Wrap the text with an Expanded widget
            child: SingleChildScrollView(
              // Allows the content to be scrollable
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  itemsString,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Text color for better readability
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
