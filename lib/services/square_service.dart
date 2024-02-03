import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart'; // Adjust the path to your Order model

class SquareService {
  final String baseUrl = 'https://connect.squareup.com/v2/orders/search';
  final String accessToken =
      'EAAAF2sWxZLxUvxa-225Q877zDt9CXuKSDrEgXTign_8iiE0io3gf7E_HjrfS3SK'; // Use a secure way to store and access your token

  Future<List<Order>> fetchOrders() async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "location_ids": ["LJK2T242684EQ"],
        "limit": 10,
        "query": {
          "filter": {
            "date_time_filter": {
              "created_at": {
                "start_at": "2024-02-02T00:00:00+00:00",
                "end_at": "2024-02-03T00:00:00+00:00"
              }
            }
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
      // Handle errors or return an empty list if there are no orders
      print('Failed to fetch orders: ${response.body}');
      return [];
    }
  }
}
