import 'dart:io';

import 'package:daisy_brew/core/error/failures.dart';
import 'package:daisy_brew/features/dashboard/data/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';
import '../entities/product_entity.dart';

class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Future<Either<Failure, List<Product>>> call() async {
    return await repository.getProducts();
  }
}

class AddProduct {
  final ProductRepository repository;

  AddProduct(this.repository);

  // Existing method (for Product with image as URL)
  Future<Either<Failure, Product>> call(Product product) async {
    return await repository.addProduct(product);
  }

  // New method to handle real file uploads
  Future<Either<Failure, Product>> callWithImage({
    required String name,
    required int price,
    required String category,
    required bool isAvailable,
    required File imageFile,
  }) async {
    return await repository.addProductWithImage(
      name: name,
      price: price,
      category: category,
      isAvailable: isAvailable,
      imageFile: imageFile,
    );
  }
}

class UpdateProduct {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  Future<Either<Failure, Product>> call(Product product) async {
    return await repository.updateProduct(product);
  }
}

class DeleteProduct {
  final ProductRepository repository;

  DeleteProduct(this.repository);

  Future<Either<Failure, void>> call(String productId) async {
    return await repository.deleteProduct(productId);
  }
}
