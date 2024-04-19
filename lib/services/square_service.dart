import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/order.dart'; // Make sure the path to your Order model is correct

class SquareService {
  // Base URL for orders
  final String ordersUrl = 'https://connect.squareup.com/v2/orders';
  // Base URL for catalog items
  final String catalogUrl = 'https://connect.squareup.com/v2/catalog/list';
  final String accessToken =
      'EAAAF2sWxZLxUvxa-225Q877zDt9CXuKSDrEgXTign_8iiE0io3gf7E_HjrfS3SK'; // Store this securely

  Future<List<String>> fetchMenuItems() async {
    final response = await http.get(
      Uri.parse(catalogUrl), // Use the catalog URL here
      headers: {
        'Square-Version': '2023-04-20',
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = (data['objects'] as List<dynamic>?)
              ?.where(
                  (obj) => obj['type'] == 'ITEM' && obj['item_data'] != null)
              .map((item) => item['item_data']['name'])
              .toList()
              .cast<String>() ??
          [];
      return items;
    } else {
      print(
          'Failed to fetch menu items: ${response.statusCode} ${response.body}');
      throw Exception(
          'Failed to fetch menu items: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<Order>> fetchOrdersFromToday() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    String formattedStartOfDay =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(startOfDay.toUtc());
    String formattedCurrentTime =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(now.toUtc());

    final response = await http.post(
      Uri.parse('$ordersUrl/search'), // Use the orders URL here
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "location_ids": ["LJK2T242684EQ"],
        "limit": 50,
        "query": {
          "filter": {
            "date_time_filter": {
              "created_at": {
                "start_at": formattedStartOfDay,
                "end_at": formattedCurrentTime
              }
            },
            // Include any additional filters here
          },
          "sort": {"sort_field": "CREATED_AT", "sort_order": "DESC"}
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Order> orders = (data['orders'] as List)
          .map((orderJson) => Order.fromJson(orderJson))
          .toList();
      return orders;
    } else {
      throw Exception('Failed to fetch orders: ${response.body}');
    }
  }
}
