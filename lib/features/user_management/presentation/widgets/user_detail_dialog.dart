import 'package:daisy_brew/features/dashboard/presentation/providers/admin_dashboard_provider.dart';
import 'package:daisy_brew/features/orders/data/models/order_model.dart';
import 'package:daisy_brew/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:daisy_brew/core/api/api_client.dart';
import 'package:daisy_brew/features/orders/presentation/providers/order_provider.dart';
import 'package:daisy_brew/features/user_management/domain/entities/user_entity.dart';
import 'package:daisy_brew/features/user_management/presentation/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class UserDetailDialog extends ConsumerStatefulWidget {
  final UserEntity? user; // null if creating
  final bool isCreate;

  const UserDetailDialog({super.key, this.user, this.isCreate = false});

  @override
  ConsumerState<UserDetailDialog> createState() => _UserDetailDialogState();
}

class _UserDetailDialogState extends ConsumerState<UserDetailDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late String selectedRole;

  List<OrderModel> orders = [];
  bool isLoadingOrders = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user?.name ?? '');
    emailController = TextEditingController(text: widget.user?.email ?? '');
    passwordController = TextEditingController();
    selectedRole = widget.user?.role ?? 'user';

    if (!widget.isCreate && widget.user != null) {
      _loadUserOrders();
    }
  }

  Future<void> _loadUserOrders() async {
    setState(() => isLoadingOrders = true);

    try {
      // Create your remote datasource
      final orderApi = OrderRemoteDatasource(ApiClient());

      // Fetch orders for this user
      final List<OrderModel> userOrders = await orderApi.getOrdersByUser(
        widget.user!.id,
      );

      // Update state
      setState(() {
        orders = userOrders;
      });
    } catch (e) {
      debugPrint('Failed to load user orders: $e');
    } finally {
      setState(() => isLoadingOrders = false);
    }
  }

  Map<String, List<OrderModel>> _groupOrdersByDate(List<OrderModel> orders) {
    final Map<String, List<OrderModel>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var order in orders) {
      final orderDate = DateTime(
        order.createdAt.year,
        order.createdAt.month,
        order.createdAt.day,
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

    return AlertDialog(
      title: Text(widget.isCreate ? 'Create User' : 'User Details'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Enter name' : null,
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Enter email' : null,
                    ),
                    if (widget.isCreate)
                      TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        obscureText: true,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter password'
                            : null,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Role: '),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: selectedRole,
                          items: const [
                            DropdownMenuItem(
                              value: 'user',
                              child: Text('User'),
                            ),
                            DropdownMenuItem(
                              value: 'admin',
                              child: Text('Admin'),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => selectedRole = value!),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (!widget.isCreate)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order History',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isLoadingOrders)
                      const Center(child: CircularProgressIndicator())
                    else if (orders.isEmpty)
                      const Text('No orders yet')
                    else
                      SizedBox(
                        height: 300,
                        child: ListView(
                          children: groupedOrders.entries.map((entry) {
                            final dateLabel = entry.key;
                            final ordersForDate = entry.value;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dateLabel,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...ordersForDate.map((order) {
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: ListTile(
                                      title: Text('Order #${order.id}'),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Status: ${order.status.name}'),
                                          Text(
                                            'Placed on: ${DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt)}',
                                          ),
                                          Text(
                                            'Total: Rs. ${order.totalPrice.toStringAsFixed(2)}',
                                          ),
                                        ],
                                      ),
                                      isThreeLine: true,
                                    ),
                                  );
                                }).toList(),
                                const SizedBox(height: 8),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (!widget.isCreate)
          TextButton(
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: const Text(
                    'Are you sure you want to delete this user?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref
                    .read(userProvider.notifier)
                    .deleteUser(widget.user!.id);

                // Refresh the dashboard
                ref.invalidate(adminDashboardProvider);

                Navigator.pop(context, true);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final notifier = ref.read(userProvider.notifier);

              if (widget.isCreate) {
                await notifier.createUser(
                  name: nameController.text,
                  email: emailController.text,
                  password: passwordController.text,
                  role: selectedRole,
                );
                ref.invalidate(adminDashboardProvider);
              } else {
                // Update role if changed
                if (selectedRole != widget.user!.role) {
                  await notifier.updateRole(widget.user!.id, selectedRole);
                }

                // Update name/email
                if (nameController.text != widget.user!.name ||
                    emailController.text != widget.user!.email) {
                  await notifier.updateUserDetails(
                    userId: widget.user!.id,
                    name: nameController.text,
                    email: emailController.text,
                  );
                }
              }

              Navigator.pop(context, true);
            }
          },
          child: Text(widget.isCreate ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}
