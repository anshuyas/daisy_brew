import 'package:daisy_brew/features/auth/data/datasources/local/cart_local_datasource.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartItems = CartLocalDataSource.items;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.brown,
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 80, color: Colors.brown),
                  SizedBox(height: 16),
                  Text('Your cart is empty!', style: TextStyle(fontSize: 20)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Image.asset(
                      item.product.image,
                      width: 50,
                      fit: BoxFit.contain,
                    ),
                    title: Text(item.product.name),
                    subtitle: Text(
                      'Qty: ${item.quantity} • Rs. ${item.product.price}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          CartLocalDataSource.removeItem(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
