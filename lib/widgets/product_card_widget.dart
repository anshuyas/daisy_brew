import 'package:flutter/material.dart';

class ProductCardWidget extends StatelessWidget {
  final String name;
  final String price;
  final VoidCallback? onAddTap;

  const ProductCardWidget({
    super.key,
    required this.name,
    required this.price,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Icon(Icons.coffee, size: 60, color: Colors.brown),
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(price),
              GestureDetector(
                onTap: onAddTap,
                child: const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.brown,
                  child: Icon(Icons.add, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
