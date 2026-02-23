import 'dart:io';

import 'package:daisy_brew/features/dashboard/domain/entities/product_entity.dart';
import 'package:daisy_brew/features/dashboard/domain/usecases/get_products.dart';
import 'package:daisy_brew/features/dashboard/presentation/providers/product_usecase_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Providers for the individual use cases
final getProductsUseCaseProvider = Provider<GetProducts>((ref) {
  final repo = ref.read(productRepositoryProvider);
  return GetProducts(repo);
});

final addProductUseCaseProvider = Provider<AddProduct>((ref) {
  final repo = ref.read(productRepositoryProvider);
  return AddProduct(repo);
});

final updateProductUseCaseProvider = Provider<UpdateProduct>((ref) {
  final repo = ref.read(productRepositoryProvider);
  return UpdateProduct(repo);
});

final deleteProductUseCaseProvider = Provider<DeleteProduct>((ref) {
  final repo = ref.read(productRepositoryProvider);
  return DeleteProduct(repo);
});

/// Main Product StateNotifier Provider
final productProvider =
    StateNotifierProvider<ProductNotifier, AsyncValue<List<Product>>>((ref) {
      final getProducts = ref.read(getProductsUseCaseProvider);
      final addProduct = ref.read(addProductUseCaseProvider);
      final updateProduct = ref.read(updateProductUseCaseProvider);
      final deleteProduct = ref.read(deleteProductUseCaseProvider);

      return ProductNotifier(
        getProducts,
        addProduct,
        updateProduct,
        deleteProduct,
      );
    });

class ProductNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final GetProducts getProducts;
  final AddProduct addProduct;
  final UpdateProduct updateProduct;
  final DeleteProduct deleteProduct;

  ProductNotifier(
    this.getProducts,
    this.addProduct,
    this.updateProduct,
    this.deleteProduct,
  ) : super(const AsyncValue.loading()) {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    state = const AsyncValue.loading();
    final result = await getProducts();
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (products) => state = AsyncValue.data(products),
    );
  }

  /// Upload a product with image file
  Future<void> uploadProduct({
    required File imageFile,
    required String name,
    required int price,
    required String category,
    required bool isAvailable,
  }) async {
    try {
      state = const AsyncValue.loading();

      // Call AddProduct use case with imageFile
      final result = await addProduct.callWithImage(
        name: name,
        price: price,
        category: category,
        isAvailable: isAvailable,
        imageFile: imageFile,
      );

      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (_) => fetchProducts(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateExistingProduct(Product product) async {
    final result = await updateProduct(product);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => fetchProducts(),
    );
  }

  Future<void> deleteExistingProduct(String id) async {
    final result = await deleteProduct(id);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => fetchProducts(),
    );
  }

  Future<void> toggleAvailability(String productId) async {
    final currentProducts = state.value;
    if (currentProducts == null) return;
    try {
      final product = state.value!.firstWhere((p) => p.id == productId);

      // Toggle availability
      final updatedProduct = Product(
        id: product.id,
        name: product.name,
        price: product.price,
        category: product.category,
        image: product.image,
        isAvailable: !product.isAvailable,
      );

      final result = await updateProduct(updatedProduct);

      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (_) {
          final updatedList = currentProducts.map((p) {
            return p.id == productId ? updatedProduct : p;
          }).toList();
          state = AsyncValue.data(updatedList);
        },
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
