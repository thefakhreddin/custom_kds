import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/order.dart'; // Make sure the path to your Order model is correct

class SquareService {
  final String baseUrl = 'https://connect.squareup.com/v2/orders';
  final String accessToken =
      'EAAAF2sWxZLxUvxa-225Q877zDt9CXuKSDrEgXTign_8iiE0io3gf7E_HjrfS3SK'; // Store this securely

  Future<List<Order>> fetchOrdersFromToday() async {
    // Get the current time and the start of the day in local time
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    // Convert to UTC and format as strings
    String formattedStartOfDay =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(startOfDay.toUtc());
    String formattedCurrentTime =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(now.toUtc());

    // Make the API call
    final response = await http.post(
      Uri.parse('$baseUrl/search'),
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
      // Parse the orders and return
      List<Order> orders = (data['orders'] as List)
          .map((orderJson) => Order.fromJson(orderJson))
          .toList();
      return orders;
    } else {
      throw Exception('Failed to fetch orders: ${response.body}');
    }
  }
}
