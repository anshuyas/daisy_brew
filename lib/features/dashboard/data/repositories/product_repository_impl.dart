import 'dart:io';

import 'package:daisy_brew/core/error/failures.dart';
import 'package:daisy_brew/features/dashboard/data/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/product_entity.dart';
import '../datasources/remote/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource remoteDatasource;

  ProductRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final products = await remoteDatasource.getProducts();
      return Right(products);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> addProduct(Product product) async {
    try {
      final newProduct = await remoteDatasource.addProduct(product);
      return Right(newProduct);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(Product product) async {
    try {
      final updatedProduct = await remoteDatasource.updateProduct(product);
      return Right(updatedProduct);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String productId) async {
    try {
      await remoteDatasource.deleteProduct(productId);
      return const Right(null);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> addProductWithImage({
    required String name,
    required int price,
    required String category,
    required bool isAvailable,
    required File imageFile,
  }) async {
    try {
      final newProduct = await remoteDatasource.addProductWithImage(
        name: name,
        price: price,
        category: category,
        isAvailable: isAvailable,
        imageFile: imageFile,
      );
      return Right(newProduct);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
