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
  Set<String> _fulfilledOrderIds = Set<String>();
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
      // Do not exclude fulfilled orders here as this will also update the all orders list
      updateOrders(fetchedOrders);
    } catch (e) {
      print('Failed to fetch orders: $e');
    }
  }

  void updateOrders(List<Order> fetchedOrders) {
    setState(() {
      // Apply the list of fulfilled order IDs to filter out those orders from all orders.
      _allOrders = fetchedOrders
          .where((order) => !_fulfilledOrderIds.contains(order.id))
          .toList();

      // Filter new orders based on the app launch time and exclude fulfilled orders.
      _newOrders = fetchedOrders.where((order) {
        return DateTime.parse(order.createdAt).isAfter(_appLaunchTime) &&
            !_fulfilledOrderIds.contains(order.id);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          toolbarHeight:
              40.0, // Adjust the height as needed to make the AppBar thinner
          backgroundColor:
              Colors.black, // Set the AppBar background color to black
          titleTextStyle: TextStyle(
              color: Colors.white), // Ensures the title, if any, is in white
          bottom: TabBar(
            controller: _tabController,
            labelColor:
                Colors.white, // Set the selected tab text color to white
            unselectedLabelColor: Colors.white.withOpacity(
                0.7), // Set the unselected tab text color to a slightly transparent white
            indicatorColor:
                Colors.white, // Optional: Changes the indicator color to white
            tabs: [
              Tab(text: 'New Orders'), // First Tab
              Tab(text: 'All Orders'), // Second Tab
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            buildOrdersTab(_newOrders, true), // Corresponds to 'New Orders' tab
            buildOrdersTab(
                _allOrders, false), // Corresponds to 'All Orders' tab
          ],
        ),
      ),
    );
  }

  void _markOrderAsFulfilled(String orderId) {
    setState(() {
      _fulfilledOrderIds.add(orderId); // Keep track of fulfilled orders
      _newOrders.removeWhere((order) => order.id == orderId);
      // Update the status on the backend if necessary
    });
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
