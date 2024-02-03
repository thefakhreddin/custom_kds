import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/square_service.dart';
import '../widgets/order_widget.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Order> _allOrders = [];
  List<Order> _newOrders = [];
  late Timer _timer;
  late TabController _tabController;
  DateTime _appLaunchTime = DateTime.now(); // Store the app launch time

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchLatestOrders();
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

  void updateOrders(List<Order> fetchedOrders) {
    setState(() {
      _allOrders = fetchedOrders;
      _newOrders = fetchedOrders.where((order) {
        return DateTime.parse(order.createdAt).isAfter(_appLaunchTime);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        backgroundColor: Colors.black, // Background color for the scaffold
        appBar: AppBar(
          title: Text('Orders',
              style: TextStyle(
                  color: Colors.white)), // Text color for AppBar title
          backgroundColor: Colors.black, // AppBar background color
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white, // Indicator color for tabs
            labelColor: Colors.white, // Label color for selected tab
            unselectedLabelColor:
                Colors.grey, // Label color for unselected tabs
            tabs: [
              Tab(text: 'New Orders'), // This tab is now the first one
              Tab(text: 'All Orders'), // This tab is now the second one
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            buildOrdersTab(_newOrders), // This tab is now the first one
            buildOrdersTab(_allOrders), // This tab is now the second one
          ],
        ),
      ),
    );
  }

  Widget buildOrdersTab(List<Order> orders) {
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
              return OrderWidget(
                  key: ValueKey(order.id), order: order, width: cardWidth);
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
