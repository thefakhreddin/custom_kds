import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';

class SquareService {
  final String ordersUrl = 'https://connect.squareup.com/v2/orders';
  final String catalogUrl = 'https://connect.squareup.com/v2/catalog/list';
  final String locationsUrl = 'https://connect.squareup.com/v2/locations';
  // final String accessToken =
  //     'EAAAF2sWxZLxUvxa-225Q877zDt9CXuKSDrEgXTign_8iiE0io3gf7E_HjrfS3SK';

  Future<String> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken') ?? '';
  }

  Future<String> fetchLocationId() async {
    String accessToken = await _getAccessToken();
    final response = await http.get(
      Uri.parse('https://connect.squareup.com/v2/locations'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['locations'] != null && data['locations'].isNotEmpty) {
        String locationId = data['locations'][0]['id'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'locationId', locationId); // Optionally save it for later use
        return locationId;
      } else {
        throw Exception("No locations found.");
      }
    } else {
      throw Exception(
          'Failed to fetch location ID: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<String>> fetchMenuItems() async {
    String accessToken = await _getAccessToken();
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
    String accessToken = await _getAccessToken();
    String locationId =
        await fetchLocationId(); // Fetch the location ID dynamically
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    String formattedStartOfDay =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(startOfDay.toUtc());
    String formattedCurrentTime =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(now.toUtc());

    final response = await http.post(
      Uri.parse('$ordersUrl/search'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "location_ids": [locationId], // Use the dynamically fetched location ID
        "limit": 50,
        "query": {
          "filter": {
            "date_time_filter": {
              "created_at": {
                "start_at": formattedStartOfDay,
                "end_at": formattedCurrentTime
              }
            },
          },
          "sort": {"sort_field": "CREATED_AT", "sort_order": "DESC"}
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['orders'] as List)
          .map((orderJson) => Order.fromJson(orderJson))
          .toList();
    } else {
      throw Exception('Failed to fetch orders: ${response.body}');
    }
  }
}
