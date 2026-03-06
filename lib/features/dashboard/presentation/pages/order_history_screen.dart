import 'package:daisy_brew/features/auth/data/datasources/local/order_local_datasource.dart';
import 'package:daisy_brew/features/dashboard/domain/entities/order_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatelessWidget {
  final String token;
  const OrderHistoryScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: const Color(0xFF8C7058),
      ),
      body: ValueListenableBuilder<List<Order>>(
        valueListenable: OrderLocalDataSource.ordersNotifier,
        builder: (context, orders, _) {
          if (orders.isEmpty) {
            return const Center(
              child: Text('No orders yet', style: TextStyle(fontSize: 18)),
            );
          }

          final groupedOrders = _groupOrdersByDate(orders);

          return ListView(
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
                            Text(
                              'Total: Rs. ${order.total.toStringAsFixed(2)}',
                            ),
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
          );
        },
      ),
    );
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

      grouped.putIfAbsent(key, () => []).add(order);
    }

    return grouped;
  }
}
