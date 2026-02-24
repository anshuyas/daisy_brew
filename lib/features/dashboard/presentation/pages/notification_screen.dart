import 'package:daisy_brew/features/auth/data/datasources/local/order_local_datasource.dart';
import 'package:daisy_brew/features/dashboard/domain/entities/order_entity.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  final String token;
  const NotificationScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    final List<Order> orders = OrderLocalDataSource.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.brown,
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[orders.length - 1 - index]; // latest first
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(
                      Icons.notifications,
                      color: Colors.brown,
                    ),
                    title: Text("Order #${order.orderNumber}"),
                    subtitle: Text(
                      "${order.items.length} item${order.items.length == 1 ? '' : 's'} • Total: Rs. ${order.total}",
                    ),
                    trailing: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;
      case "preparing":
        return Colors.blue;
      case "ready":
        return Colors.purple;
      case "delivered":
        return Colors.green;
      case "canceled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getNotificationMessage(Order order) {
    switch (order.status) {
      case "preparing":
        return "Your order is being prepared";
      case "ready":
        return "Your order is ready for pickup";
      case "delivered":
        return "Your order has been delivered";
      case "canceled":
        return "Your order was canceled";
      default:
        return "Order placed successfully";
    }
  }
}
