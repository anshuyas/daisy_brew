import 'package:daisy_brew/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../widgets/user_detail_dialog.dart';

class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Field
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search by name or email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16),
            // Users List
            Expanded(
              child: usersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
                data: (users) {
                  // Filter users by search query
                  final filteredUsers = users
                      .where(
                        (u) =>
                            u.name.toLowerCase().contains(searchQuery) ||
                            u.email.toLowerCase().contains(searchQuery),
                      )
                      .toList();

                  if (filteredUsers.isEmpty) {
                    return const Center(child: Text('No users found'));
                  }

                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return Card(
                        child: ListTile(
                          title: Text(user.name),
                          subtitle: Text(
                            '${user.email} • Orders: ${user.totalOrders}',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'toggle_role') {
                                final newRole = user.role == 'admin'
                                    ? 'user'
                                    : 'admin';

                                await ref
                                    .read(userProvider.notifier)
                                    .updateRole(user.id, newRole);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Role updated to $newRole"),
                                  ),
                                );
                              }

                              final currentUserEmail = ref
                                  .read(authStateProvider)
                                  .email;

                              if (currentUserEmail == user.email) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("You cannot delete yourself"),
                                  ),
                                );
                                return;
                              }
                              if (value == 'delete_user') {
                                final confirm = await showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Delete User"),
                                    content: const Text(
                                      "Are you sure you want to delete this user?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await ref
                                      .read(userProvider.notifier)
                                      .deleteUser(user.id);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "User deleted successfully",
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'toggle_role',
                                child: Text(
                                  user.role == 'admin'
                                      ? 'Make User'
                                      : 'Make Admin',
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete_user',
                                child: Text(
                                  'Delete User',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                            icon: const Icon(Icons.more_vert),
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
      ),
    );
  }
}
