import 'package:flutter/material.dart';

class ProductCardWidget extends StatelessWidget {
  final String name;
  final String price;
  final String imagePath;
  final VoidCallback? onAddTap;

  const ProductCardWidget({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(child: Image.asset(imagePath, fit: BoxFit.contain)),
          ),
          const SizedBox(height: 8),
          Text(name, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(price, style: Theme.of(context).textTheme.bodyMedium),
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
