import 'order_product.dart';
import 'order_status.dart';

class AdminOrder {
  final String id;
  final String userId;
  final String customerName;
  final String customerEmail;
  final List<OrderProduct> products;
  final double totalPrice;
  final OrderStatus status;
  final DateTime createdAt;

  AdminOrder({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.products,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });
}
