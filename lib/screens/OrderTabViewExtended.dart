// order_tab_view.dart
import 'package:flutter/material.dart';
import 'package:newkds/models/order.dart';
import 'package:newkds/models/menu_selection.dart';
import 'package:newkds/widgets/order_widget_extended.dart';
import 'package:provider/provider.dart';

class OrdersTabViewExtended extends StatefulWidget {
  final List<Order> orders;
  final bool isNewOrdersTab;
  final Function(String) onOrderFulfilled;

  const OrdersTabViewExtended({
    Key? key,
    required this.orders,
    required this.isNewOrdersTab,
    required this.onOrderFulfilled,
  }) : super(key: key);

  @override
  _OrdersTabViewExtendedState createState() => _OrdersTabViewExtendedState();
}

class _OrdersTabViewExtendedState extends State<OrdersTabViewExtended> {
  Map<String, double> opacityValues = {};

  @override
  Widget build(BuildContext context) {
    Set<String> selectedItems =
        Provider.of<MenuSelectionModel>(context, listen: false).selectedItems;

    List<Order> filteredOrders = widget.orders
        .where((order) =>
            order.items.any((item) => selectedItems.contains(item.name)))
        .toList();

    return filteredOrders.isEmpty
        ? Center(
            child:
                Text('No orders found', style: TextStyle(color: Colors.white)))
        : ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: filteredOrders.length,
            itemBuilder: (context, i) {
              var index =
                  widget.isNewOrdersTab ? filteredOrders.length - i - 1 : i;
              final order = filteredOrders[index];
              final double cardWidth =
                  MediaQuery.of(context).size.width / 2 - 16;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    opacityValues[order.id] = 0.5; // Set opacity to 0.5 on tap
                  });
                  Future.delayed(Duration(seconds: 1), () {
                    widget.onOrderFulfilled(order.id);
                    setState(() {
                      opacityValues[order.id] =
                          1.0; // Reset opacity back to 1.0
                    });
                  });
                },
                child: Opacity(
                  opacity:
                      opacityValues[order.id] ?? 1.0, // Use dynamic opacity
                  child: Container(
                    width: cardWidth,
                    decoration: getDecoration(order, widget.isNewOrdersTab),
                    child: OrderWidgetExtended(
                      key: ValueKey(order.id),
                      order: order,
                      width: cardWidth,
                    ),
                  ),
                ),
              );
            },
          );
  }
}

BoxDecoration getDecoration(Order order, bool isNewOrdersTab) {
  if (!isNewOrdersTab) {
    return BoxDecoration(borderRadius: BorderRadius.circular(10));
  }

  final currentTime = DateTime.now();
  final orderTime = DateTime.parse(order.createdAt).toLocal();
  final elapsedTime = currentTime.difference(orderTime).inMinutes;

  final int yellowThreshold =
      5; // Placeholder, replace with value from SharedPreferences
  final int redThreshold =
      10; // Placeholder, replace with value from SharedPreferences

  if (elapsedTime > redThreshold) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.red,
    );
  } else if (elapsedTime > yellowThreshold) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.yellow,
    );
  } else {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
    );
  }
}
