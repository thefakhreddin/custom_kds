import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/square_service.dart'; // Adjust the import path as needed
import '../widgets/order_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Order>> ordersFuture;

  @override
  void initState() {
    super.initState();
    ordersFuture = SquareService().fetchOrders(); // Fetch orders on init
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<Order>>(
        future: ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.hasData) {
              return GridView.custom(
                padding: EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200, // Maximum extent of each grid item
                  childAspectRatio: 3 / 4, // Aspect ratio of each grid card
                  crossAxisSpacing: 8, // Horizontal space between cards
                  mainAxisSpacing: 8, // Vertical space between cards
                ),
                childrenDelegate: SliverChildBuilderDelegate(
                  (context, index) => OrderWidget(order: snapshot.data![index]),
                  childCount: snapshot.data!.length,
                ),
              );
            } else {
              return Center(child: Text('No orders found'));
            }
          }
          // Show a loading spinner while the orders are being fetched
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
