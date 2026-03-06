import 'dart:convert';

import 'package:daisy_brew/features/dashboard/domain/entities/cart_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartLocalDataSource {
  static final List<CartItem> _items = [];

  static List<CartItem> get items => _items;

  static const String _cartKey = 'cart_items';

  // Load cart from local storage
  static Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cartKey);

    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _items.clear();
      _items.addAll(jsonList.map((json) => CartItem.fromJson(json)).toList());
    }
  }

  // Save cart to local storage
  static Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_items.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKey, jsonString);
  }

  //Add item and save
  static Future<void> addItem(CartItem item) async {
    _items.add(item);
    await _saveCart();
  }

  // Remove item and save
  static Future<void> removeItem(int index) async {
    _items.removeAt(index);
    await _saveCart();
  }

  // Clear cart and save
  static Future<void> clear() async {
    _items.clear();
    await _saveCart();
  }
}
