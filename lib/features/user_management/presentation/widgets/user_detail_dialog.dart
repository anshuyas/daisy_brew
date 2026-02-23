import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../../domain/entities/user_entity.dart';

class UserDetailDialog extends ConsumerStatefulWidget {
  final UserEntity user;

  const UserDetailDialog({super.key, required this.user});

  @override
  ConsumerState<UserDetailDialog> createState() => _UserDetailDialogState();
}

class _UserDetailDialogState extends ConsumerState<UserDetailDialog> {
  late String selectedRole;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.user.role;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('User Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Name: ${widget.user.name}'),
          Text('Email: ${widget.user.email}'),
          Text('Total Orders: ${widget.user.totalOrders}'),
          const SizedBox(height: 16),
          // Role Dropdown
          Row(
            children: [
              const Text('Role: '),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Delete Button
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
              await ref.read(userProvider.notifier).deleteUser(widget.user.id);
              Navigator.pop(context, true); // close detail dialog
            }
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),

        // Update Role Button
        TextButton(
          onPressed: () async {
            if (selectedRole != widget.user.role) {
              await ref
                  .read(userProvider.notifier)
                  .updateRole(widget.user.id, selectedRole);
            }
            Navigator.pop(context, true); // close dialog
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
