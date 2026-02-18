import 'package:daisy_brew/features/dashboard/domain/entities/cart_item.dart';

class CartLocalDataSource {
  static final List<CartItem> _items = [];

  static List<CartItem> get items => _items;

  static void addItem(CartItem item) {
    _items.add(item);
  }

  static void removeItem(int index) {
    _items.removeAt(index);
  }

  static void clear() {
    _items.clear();
  }
}
