import 'dart:io';

import 'package:daisy_brew/core/error/failures.dart';
import 'package:daisy_brew/features/dashboard/domain/entities/product_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> addProduct(Product product);
  Future<Either<Failure, Product>> updateProduct(Product product);
  Future<Either<Failure, void>> deleteProduct(String productId);

  Future<Either<Failure, Product>> addProductWithImage({
    required String name,
    required int price,
    required String category,
    required bool isAvailable,
    required File imageFile,
  });
}
