import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  final String token;
  const NotificationScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.brown,
      ),
      body: const Center(
        child: Text('No notifications yet', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
