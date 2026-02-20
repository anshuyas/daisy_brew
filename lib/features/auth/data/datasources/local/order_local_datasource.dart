// lib/features/dashboard/data/datasources/local/order_local_datasource.dart
import 'dart:convert';

import 'package:daisy_brew/features/dashboard/domain/entities/order_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderLocalDataSource {
  static final List<Order> _orders = [];

  static List<Order> get orders => _orders;

  static const String _ordersKey = 'order_history';

  // Load all orders from local storage
  static Future<void> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_ordersKey);

    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _orders.clear();
      _orders.addAll(jsonList.map((json) => Order.fromJson(json)).toList());
    }
  }

  // Save all orders to local storage
  static Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(
      _orders.map((order) => order.toJson()).toList(),
    );
    await prefs.setString(_ordersKey, jsonString);
  }

  // Add a new order and save
  static Future<void> addOrder(Order order) async {
    _orders.insert(0, order); // insert at top to show recent orders first
    await _saveOrders();
  }

  // Clear all orders
  static Future<void> clearOrders() async {
    _orders.clear();
    await _saveOrders();
  }

  // Optional: update status of a specific order
  static Future<void> updateOrderStatus(
    String orderNumber,
    String newStatus,
  ) async {
    final index = _orders.indexWhere((o) => o.orderNumber == orderNumber);
    if (index != -1) {
      _orders[index] = Order(
        orderNumber: _orders[index].orderNumber,
        dateTime: _orders[index].dateTime,
        items: _orders[index].items,
        status: newStatus,
        total: _orders[index].total,
      );
      await _saveOrders();
    }
  }
}
