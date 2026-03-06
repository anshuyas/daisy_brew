import 'package:daisy_brew/features/orders/domain/entities/admin_order.dart';
import '../repositories/order_repository.dart';

class SearchOrders {
  final OrderRepository repository;

  SearchOrders(this.repository);

  Future<List<AdminOrder>> call(String query) {
    return repository.searchOrders(query);
  }
}
