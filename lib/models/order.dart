class Order {
  final String id;
  final List<OrderItem> items;
  final String createdAt;
  final String state;

  Order({
    required this.id,
    required this.items,
    required this.createdAt,
    required this.state,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var lineItemsJson = json['line_items'] as List<dynamic>? ?? [];
    List<OrderItem> items =
        lineItemsJson.map((itemJson) => OrderItem.fromJson(itemJson)).toList();

    String id = json['id'] as String? ?? 'Unknown ID';
    String createdAt = json['created_at'] as String? ?? 'Unknown Time';
    String state = json['state'] as String? ?? 'Unknown State';

    return Order(
      id: id,
      items: items,
      createdAt: createdAt,
      state: state,
    );
  }
}

class OrderItem {
  final String uid;
  final String name;
  final String quantity;

  OrderItem({
    required this.uid,
    required this.name,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      uid: json['uid'] as String? ?? 'Unknown UID',
      name: json['name'] as String? ?? 'Unknown Item',
      quantity: json['quantity'] as String? ?? '0',
    );
  }
}
