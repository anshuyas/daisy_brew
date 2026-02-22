import 'package:daisy_brew/features/auth/data/datasources/local/order_local_datasource.dart';
import 'package:daisy_brew/features/dashboard/domain/entities/order_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  final String token;
  const OrderHistoryScreen({super.key, required this.token});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    await OrderLocalDataSource.loadOrders();
    setState(() {
      orders = OrderLocalDataSource.orders;
    });
  }

  Map<String, List<Order>> _groupOrdersByDate(List<Order> orders) {
    final Map<String, List<Order>> grouped = {};

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var order in orders) {
      final orderDate = DateTime(
        order.dateTime.year,
        order.dateTime.month,
        order.dateTime.day,
      );
      String key;

      if (orderDate == today) {
        key = 'Today';
      } else if (orderDate == yesterday) {
        key = 'Yesterday';
      } else {
        key = 'Earlier';
      }

      if (!grouped.containsKey(key)) grouped[key] = [];
      grouped[key]!.add(order);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedOrders = _groupOrdersByDate(orders);

    if (orders.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Order History'),
          backgroundColor: const Color(0xFF8C7058),
        ),
        body: const Center(
          child: Text('No orders yet', style: TextStyle(fontSize: 18)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: const Color(0xFF8C7058),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: groupedOrders.entries.map((entry) {
          final dateLabel = entry.key;
          final ordersForDate = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...ordersForDate.map((order) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text('Your Order #${order.orderNumber}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${order.status}'),
                        Text(
                          'Placed on: ${DateFormat('dd MMM yyyy, hh:mm a').format(order.dateTime)}',
                        ),
                        Text('Total: Rs. ${order.total.toStringAsFixed(2)}'),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}
