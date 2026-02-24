import 'package:daisy_brew/features/orders/domain/entities/admin_order.dart';

import '../../domain/entities/order_status.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDatasource remoteDatasource;

  OrderRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<AdminOrder>> getOrders() {
    return remoteDatasource.getOrders();
  }

  @override
  Future<AdminOrder> getOrderById(String id) {
    return remoteDatasource.getOrderById(id);
  }

  @override
  Future<void> updateOrderStatus(String id, OrderStatus status) {
    return remoteDatasource.updateOrderStatus(id, status.value);
  }

  @override
  Future<List<AdminOrder>> searchOrders(String query) {
    return remoteDatasource.searchOrders(query);
  }

  @override
  Future<List<AdminOrder>> filterOrders({
    String? status,
    String? orderType,
    DateTime? date,
  }) {
    return remoteDatasource.filterOrders(
      status: status,
      orderType: orderType,
      date: date,
    );
  }
}
