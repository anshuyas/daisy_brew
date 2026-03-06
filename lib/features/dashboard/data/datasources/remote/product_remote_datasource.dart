import 'dart:io';

import 'package:daisy_brew/core/api/api_client.dart';
import 'package:daisy_brew/features/dashboard/domain/entities/product_entity.dart';
import 'package:dio/dio.dart';

class ProductRemoteDatasource {
  final ApiClient client;

  ProductRemoteDatasource({required this.client});

  // Fetch all products
  Future<List<Product>> getProducts({bool onlyAvailable = true}) async {
    final query = onlyAvailable ? '?available=true' : '';
    final data = await client.get("/products$query") as List;
    return data.map((e) => Product.fromJson(e)).toList();
  }

  // Add a new product
  Future<Product> addProduct(Product product) async {
    final data = await client.post("/products", data: product.toJson());
    return Product.fromJson(data);
  }

  // Update an existing product
  Future<Product> updateProduct(Product product) async {
    final data = await client.put(
      "/products/${product.id}",
      data: product.toJson(),
    );
    return Product.fromJson(data);
  }

  // Delete a product
  Future<void> deleteProduct(String productId) async {
    await client.delete("/products/$productId");
  }

  Future<Product> addProductWithImage({
    required String name,
    required int price,
    required String category,
    required bool isAvailable,
    required File imageFile,
  }) async {
    // Create FormData for multipart upload
    final formData = FormData.fromMap({
      'name': name,
      'price': price,
      'category': category,
      'isAvailable': isAvailable,
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
    });

    // POST request using your ApiClient
    final data = await client.post("/products", data: formData);

    return Product.fromJson(data);
  }
}
