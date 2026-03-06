import 'package:daisy_brew/features/dashboard/domain/entities/cart_entity.dart';

class Order {
  final String orderNumber;
  final DateTime dateTime;
  final List<CartItem> items;
  final String status;
  final double total;

  Order({
    required this.orderNumber,
    required this.dateTime,
    required this.items,
    required this.status,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
    'orderNumber': orderNumber,
    'dateTime': dateTime.toIso8601String(),
    'items': items.map((e) => e.toJson()).toList(),
    'status': status,
    'total': total,
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    orderNumber: json['orderNumber'],
    dateTime: DateTime.parse(json['dateTime']),
    items: (json['items'] as List).map((e) => CartItem.fromJson(e)).toList(),
    status: json['status'],
    total: (json['total'] as num).toDouble(),
  );
}
