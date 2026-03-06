import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daisy_brew/core/api/api_client.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/repositories/order_repository.dart';

/// Remote DataSource Provider
final orderRemoteDatasourceProvider = Provider<OrderRemoteDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return OrderRemoteDatasource(apiClient);
});

/// Repository Provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final remoteDatasource = ref.read(orderRemoteDatasourceProvider);
  return OrderRepositoryImpl(remoteDatasource);
});
