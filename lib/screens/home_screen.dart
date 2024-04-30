import 'package:flutter/material.dart';
import 'package:newkds/screens/OrderTabViewExtended.dart';
import 'package:newkds/screens/OrderTabViewVertical.dart';
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
  List<Order> _recalledOrders = [];
  List<String> _menuItems = []; // To store menu item names
  late Timer _timer;
  late TabController _tabController;
  DateTime _appLaunchTime = DateTime.now();
  bool _apiError = false;
  int layoutIndex = 0;
  String shopName = 'Kitchen Display';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchLatestOrders();
    _fetchMenuItems();
    fetchShopName();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchLatestOrders();
    });
  }

  Future _fetchLatestOrders() async {
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

  void fetchShopName() async {
    try {
      String fetchedName = await SquareService().fetchShopName();
      setState(() {
        shopName = fetchedName; // Update shop name on successful fetch
        _apiError = false; // Reset any previous error state
      });
    } catch (e) {
      setState(() {
        _apiError = true; // Set error state on fetch failure
        print('Failed to fetch shop name: $e');
      });
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
      _allOrders = fetchedOrders;
      _newOrders = fetchedOrders.where((order) {
        return DateTime.parse(order.createdAt).isAfter(_appLaunchTime) &&
            !_fulfilledOrderIds.contains(order.id);
      }).toList();
    });
  }

  void _markOrderAsFulfilled(String orderId) {
    setState(() {
      if (!_fulfilledOrderIds.contains(orderId)) {
        _fulfilledOrderIds.add(orderId);
      }
      _newOrders.removeWhere((order) => order.id == orderId);
      _recalledOrders.removeWhere((order) => order.id == orderId);
    });
  }

  void _unmarkOrderAsFulfilled(String orderId) {
    setState(() {
      Order? orderToReintroduce =
          _allOrders.firstWhere((order) => order.id == orderId);
      orderToReintroduce.isRecalled = true;
      _recalledOrders.add(orderToReintroduce);
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
            : shopName), // Sets the title of the AppBar
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
              icon: Icon(Icons.auto_awesome_mosaic),
              onPressed: () => setState(() {
                    layoutIndex =
                        (layoutIndex + 1) % 3; // Cycles through 0, 1, and 2
                  })),
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
          RefreshIndicator(
            child: orderTabView(layoutIndex, _recalledOrders + _newOrders, true,
                _markOrderAsFulfilled),
            onRefresh: _fetchLatestOrders,
          ),
          RefreshIndicator(
            child: orderTabView(
                layoutIndex, _allOrders, false, _unmarkOrderAsFulfilled),
            onRefresh: _fetchLatestOrders,
          )
        ],
      ),
    );
  }

  Widget orderTabView(index, orders, isNewOrdersTab, onOrderFulfilled) {
    if (index == 0) {
      {
        return OrdersTabView(
            orders: orders,
            isNewOrdersTab: isNewOrdersTab,
            onOrderFulfilled: onOrderFulfilled);
      }
    } else if (index == 1) {
      return OrdersTabViewExtended(
          orders: orders,
          isNewOrdersTab: isNewOrdersTab,
          onOrderFulfilled: onOrderFulfilled);
    }
    return OrdersTabViewVertical(
        orders: orders,
        isNewOrdersTab: isNewOrdersTab,
        onOrderFulfilled: onOrderFulfilled);
  }

  @override
  void dispose() {
    _timer.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _refreshData() {
    fetchShopName();
    _fetchMenuItems();
    _fetchLatestOrders();
  }
}
