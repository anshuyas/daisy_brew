import 'product_entity.dart';

class CartItem {
  final Product product;
  final int quantity;
  final int? size;
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
}
