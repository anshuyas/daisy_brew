import 'package:daisy_brew/features/dashboard/data/datasources/remote/product_remote_datasource.dart';
import 'package:daisy_brew/features/dashboard/data/repositories/product_repository_impl.dart';
import 'package:daisy_brew/features/dashboard/domain/usecases/get_products.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daisy_brew/core/api/api_client.dart';

// Repository provider
final productRepositoryProvider = Provider<ProductRepositoryImpl>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final remoteDataSource = ProductRemoteDatasource(client: apiClient);
  return ProductRepositoryImpl(remoteDatasource: remoteDataSource);
});

// Get Products UseCase provider
final getProductsUseCaseProvider = Provider<GetProducts>((ref) {
  final repository = ref.read(productRepositoryProvider);
  return GetProducts(repository);
});
