import 'package:daisy_brew/features/orders/presentation/pages/order_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/order_status.dart';
import '../providers/order_provider.dart';

class AdminOrdersPage extends ConsumerStatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  ConsumerState<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends ConsumerState<AdminOrdersPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Orders")),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by customer name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) async {
                setState(() {
                  searchQuery = value;
                });

                // Call the provider's search method
                await ref.read(orderProvider.notifier).search(value);
              },
            ),
          ),
          // Orders List
          Expanded(
            child: ordersState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (orders) {
                if (orders.isEmpty) {
                  return const Center(child: Text("No orders found"));
                }

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (_, index) {
                    final order = orders[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
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
                              builder: (_) =>
                                  OrderDetailsPage(orderId: order.id),
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
          ),
        ],
      ),
    );
  }
}
