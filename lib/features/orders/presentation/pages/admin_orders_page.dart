import 'package:daisy_brew/features/orders/presentation/pages/order_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/order_status.dart';
import '../providers/order_provider.dart';

class AdminOrdersPage extends ConsumerWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Orders")),
      body: ordersState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (orders) {
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (_, index) {
              final order = orders[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(order.customerName),
                  subtitle: Text(
                    "Rs ${order.totalPrice} • ${order.status.value}",
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailsPage(orderId: order.id),
                      ),
                    );
                  },
                  trailing: DropdownButton<OrderStatus>(
                    value: order.status,
                    items: OrderStatus.values
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.value),
                          ),
                        )
                        .toList(),
                    onChanged: (newStatus) {
                      if (newStatus != null) {
                        ref
                            .read(orderProvider.notifier)
                            .updateStatus(order.id, newStatus);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
