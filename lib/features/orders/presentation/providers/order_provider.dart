import 'package:daisy_brew/features/orders/domain/entities/admin_order.dart';
import 'package:daisy_brew/features/orders/presentation/providers/order_dependencies.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/repositories/order_repository.dart';

class OrderNotifier extends AsyncNotifier<List<AdminOrder>> {
  late OrderRepository repository;

  @override
  Future<List<AdminOrder>> build() async {
    repository = ref.read(orderRepositoryProvider);
    return repository.getOrders();
  }

  Future<void> refreshOrders() async {
    state = const AsyncLoading();
    state = AsyncData(await repository.getOrders());
  }

  Future<void> search(String query) async {
    state = const AsyncLoading();
    state = AsyncData(await repository.searchOrders(query));
  }

  Future<void> updateStatus(String id, OrderStatus status) async {
    await repository.updateOrderStatus(id, status);
    await refreshOrders();
  }
}

final orderProvider = AsyncNotifierProvider<OrderNotifier, List<AdminOrder>>(
  OrderNotifier.new,
);
