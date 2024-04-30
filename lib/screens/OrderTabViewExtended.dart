// order_tab_view.dart
import 'package:flutter/material.dart';
import 'package:newkds/models/order.dart';
import 'package:newkds/models/menu_selection.dart';
import 'package:newkds/widgets/order_widget_extended.dart';
import 'package:provider/provider.dart';

class OrdersTabViewExtended extends StatelessWidget {
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
        : ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              final double cardWidth =
                  MediaQuery.of(context).size.width / 2 - 16;
              return GestureDetector(
                onTap: isNewOrdersTab ? () => onOrderFulfilled(order.id) : null,
                child: OrderWidgetExtended(
                    key: ValueKey(order.id), order: order, width: cardWidth),
              );
            },
          );
  }
}
