// order_tab_view.dart
import 'package:flutter/material.dart';
import 'package:newkds/models/order.dart';
import 'package:newkds/models/menu_selection.dart';
import 'package:newkds/widgets/order_widget.dart';
import 'package:provider/provider.dart';

class OrdersTabView extends StatelessWidget {
  final List<Order> orders;
  final bool isNewOrdersTab;
  final Function(String) onOrderFulfilled;

  const OrdersTabView({
    Key? key,
    required this.orders,
    required this.isNewOrdersTab,
    required this.onOrderFulfilled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Set<String> selectedItems =
        Provider.of<MenuSelectionModel>(context, listen: false).selectedItems;

    List<Order> filteredOrders = orders
        .where((order) =>
            order.items.any((item) => selectedItems.contains(item.name)))
        .toList();

    return filteredOrders.isEmpty
        ? Center(
            child:
                Text('No orders found', style: TextStyle(color: Colors.white)))
        : GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: filteredOrders.length,
            itemBuilder: (context, i) {
              var index = isNewOrdersTab ? filteredOrders.length - i - 1 : i;
              final order = filteredOrders[index];
              final double cardWidth =
                  MediaQuery.of(context).size.width / 2 - 16;
              return GestureDetector(
                onTap: () => onOrderFulfilled(order.id),
                child: Container(
                  decoration: getDecoration(order, isNewOrdersTab),
                  child: OrderWidget(
                      key: ValueKey(order.id), order: order, width: cardWidth),
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
