import 'package:daisy_brew/features/orders/domain/entities/admin_order.dart';
import '../repositories/order_repository.dart';

class GetOrderDetails {
  final OrderRepository repository;

  GetOrderDetails(this.repository);

  Future<AdminOrder> call(String id) {
    return repository.getOrderById(id);
  }
}
