import 'package:daisy_brew/features/orders/domain/entities/admin_order.dart';
import '../repositories/order_repository.dart';

class GetOrders {
  final OrderRepository repository;

  GetOrders(this.repository);

  Future<List<AdminOrder>> call() {
    return repository.getOrders();
  }
}
