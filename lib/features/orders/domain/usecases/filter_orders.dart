import 'package:daisy_brew/features/orders/domain/entities/admin_order.dart';

import '../repositories/order_repository.dart';

class FilterOrders {
  final OrderRepository repository;

  FilterOrders(this.repository);

  Future<List<AdminOrder>> call({
    String? status,
    String? orderType,
    DateTime? date,
  }) {
    return repository.filterOrders(
      status: status,
      orderType: orderType,
      date: date,
    );
  }
}
