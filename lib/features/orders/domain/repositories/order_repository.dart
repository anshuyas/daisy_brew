import 'package:daisy_brew/features/orders/domain/entities/admin_order.dart';

import '../entities/order_status.dart';

abstract class OrderRepository {
  Future<List<AdminOrder>> getOrders();

  Future<AdminOrder> getOrderById(String id);

  Future<void> updateOrderStatus(String id, OrderStatus status);

  Future<List<AdminOrder>> searchOrders(String query);

  Future<List<AdminOrder>> filterOrders({
    String? status,
    String? orderType,
    DateTime? date,
  });
}
