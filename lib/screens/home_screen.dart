import 'package:flutter/material.dart';
import 'package:newkds/screens/OrderTabViewExtended.dart';
import 'package:newkds/screens/OrdersTabView.dart';
import 'package:newkds/screens/settings_page.dart';
import '../models/order.dart';
import '../services/square_service.dart';
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
  bool _apiError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      if (_apiError) {
        // Reset error state if the call is now successful
        setState(() {
          _apiError = false;
        });
      }
    } catch (e) {
      print('Failed to fetch orders: $e');
      if (!_apiError) {
        // Set error state if an exception is caught
        setState(() {
          _apiError = true;
        });
      }
    }
  }

  void _fetchMenuItems() async {
    try {
      var fetchedItems = await SquareService().fetchMenuItems();
      setState(() {
        _menuItems = fetchedItems;
        if (_apiError) {
          // Reset error state if the call is now successful
          _apiError = false;
        }
      });
    } catch (e) {
      print('Failed to fetch menu items: $e');
      if (!_apiError) {
        // Set error state if an exception is caught
        setState(() {
          _apiError = true;
        });
      }
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
        title: Text(_apiError
            ? 'Connecting...'
            : 'Kitchen Display'), // Sets the title of the AppBar
        actions: [
          IconButton(
            icon: Icon(
                Icons.filter_list), // Using filter_list icon for menu items
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MenuItemsScreen(menuItems: _menuItems)),
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              // Navigate to the SettingsPage and await the result
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SettingsPage(onTokenChanged: _refreshData),
                ),
              );
              // Check if the settings told us to refresh
              if (result == true) {
                _refreshData();
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'New Orders'),
            Tab(text: 'All Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OrdersTabViewExtended(
              orders: _newOrders,
              isNewOrdersTab: true,
              onOrderFulfilled: _markOrderAsFulfilled),
          OrdersTabViewExtended(
              orders: _allOrders,
              isNewOrdersTab: false,
              onOrderFulfilled: _markOrderAsFulfilled),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _refreshData() {
    _fetchMenuItems();
    _fetchLatestOrders();
  }
}
