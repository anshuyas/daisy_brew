import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  final String token;
  const OrderHistoryScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: Colors.brown,
      ),
      body: const Center(
        child: Text('No orders yet', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
