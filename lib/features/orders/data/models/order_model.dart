import 'package:daisy_brew/features/orders/domain/entities/admin_order.dart';
import '../../domain/entities/order_product.dart';
import '../../domain/entities/order_status.dart';

class OrderModel extends AdminOrder {
  OrderModel({
    required String id,
    required String userId,
    required String customerName,
    required String customerEmail,
    required List<OrderProduct> products,
    required double totalPrice,
    required OrderStatus status,
    required DateTime createdAt,
  }) : super(
         id: id,
         userId: userId,
         customerName: customerName,
         customerEmail: customerEmail,
         products: products,
         totalPrice: totalPrice,
         status: status,
         createdAt: createdAt,
       );

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? '',
      userId: json['user'] is Map ? json['user']['_id'] : json['user'],

      customerName: json['user'] is Map ? json['user']['fullName'] ?? '' : '',

      customerEmail: json['user'] is Map ? json['user']['email'] ?? '' : '',

      products: (json['products'] as List)
          .map(
            (p) => OrderProduct(
              productId: p['_id'] ?? '',
              name: p['name'] ?? p['product'] ?? '',
              quantity: p['quantity'] ?? 0,
              price: (p['price'] as num?)?.toDouble() ?? 0,
            ),
          )
          .toList(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      status: OrderStatusX.fromString(json['status'] ?? 'pending'),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
