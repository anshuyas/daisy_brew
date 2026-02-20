import 'product_entity.dart';

class CartItem {
  final Product product;
  final int quantity;
  final double? size;
  final bool? isHot;
  final int? sugar;
  final String? milk;

  CartItem({
    required this.product,
    required this.quantity,
    this.size,
    this.isHot,
    this.sugar,
    this.milk,
  });

  // Convert CartItem to JSON
  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
    'size': size,
    'isHot': isHot,
    'sugar': sugar,
    'milk': milk,
  };

  // Create CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    product: Product.fromJson(json['product']),
    quantity: json['quantity'],
    size: json['size'],
    isHot: json['isHot'],
    sugar: json['sugar'],
    milk: json['milk'],
  );
}
