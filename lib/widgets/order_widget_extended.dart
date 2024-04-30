import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newkds/models/order.dart';

class OrderWidgetExtended extends StatelessWidget {
  final Order order;
  final double width;

  const OrderWidgetExtended({
    Key? key,
    required this.order,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Formatting each item and variation as specified
    final itemsWidgets = order.items
        .map((item) => RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                    text:
                        '${item.quantity}x ${item.name}\n', // Order name and quantity
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: item.variationName.isNotEmpty
                        ? '${item.variationName}\n'
                        : '\n', // Variation details
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ))
        .toList();

    final dateTime = DateTime.parse(order.createdAt).toLocal();
    final formattedTime = DateFormat('hh:mm a').format(dateTime);

    return Container(
      width: width,
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[850],
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
          SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              children: itemsWidgets,
            ),
          ),
        ],
      ),
    );
  }
}
