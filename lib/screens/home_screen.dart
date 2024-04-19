import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/square_service.dart';
import '../widgets/order_widget.dart';
import '../screens/menu_items_screen.dart'; // Assuming you've created this new screen
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  Set<String> _fulfilledOrderIds = Set<String>();
  List<Order> _allOrders = [];
  List<Order> _newOrders = [];
  List<String> _menuItems = []; // To store menu item names
  late Timer _timer;
  late TabController _tabController;
  DateTime _appLaunchTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchLatestOrders();
    _fetchMenuItems();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchLatestOrders();
    });
  }

  void _fetchLatestOrders() async {
    try {
      var fetchedOrders = await SquareService().fetchOrdersFromToday();
      updateOrders(fetchedOrders);
    } catch (e) {
      print('Failed to fetch orders: $e');
    }
  }

  void _fetchMenuItems() async {
    try {
      var fetchedItems =
          await SquareService().fetchMenuItems(); // Assuming this method exists
      setState(() {
        _menuItems = fetchedItems;
      });
    } catch (e) {
      print('Failed to fetch menu items: $e');
    }
  }

  void updateOrders(List<Order> fetchedOrders) {
    setState(() {
      _allOrders = fetchedOrders
          .where((order) => !_fulfilledOrderIds.contains(order.id))
          .toList();
      _newOrders = fetchedOrders.where((order) {
        return DateTime.parse(order.createdAt).isAfter(_appLaunchTime) &&
            !_fulfilledOrderIds.contains(order.id);
      }).toList();
    });
  }

  void _markOrderAsFulfilled(String orderId) {
    setState(() {
      _fulfilledOrderIds.add(orderId);
      _newOrders.removeWhere((order) => order.id == orderId);
      // Here you could also update the backend or API to reflect the order status change
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 40.0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'New Orders'),
            Tab(text: 'All Orders'),
            Tab(text: 'Menu Items'), // Make sure the count here is 3
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildOrdersTab(_newOrders, true),
          buildOrdersTab(_allOrders, false),
          MenuItemsScreen(
              menuItems:
                  _menuItems), // Ensure this is also initialized correctly
        ],
      ),
    );
  }

  Widget buildOrdersTab(List<Order> orders, bool isNewOrdersTab) {
    return orders.isEmpty
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
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final double cardWidth =
                  MediaQuery.of(context).size.width / 2 - 16;
              return GestureDetector(
                onTap: isNewOrdersTab
                    ? () => _markOrderAsFulfilled(order.id)
                    : null,
                child: OrderWidget(
                    key: ValueKey(order.id), order: order, width: cardWidth),
              );
            },
          );
  }

  @override
  void dispose() {
    _timer.cancel();
    _tabController.dispose();
    super.dispose();
  }
}
