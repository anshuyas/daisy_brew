import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    print("IMAGE PATH RECEIVED >>> '$imagePath'");
    print(
      "STARTS WITH HTTP? >>> ${imagePath.toLowerCase().startsWith('http')}",
    );
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imagePath.contains('http')
                  ? CachedNetworkImage(
                      imageUrl: imagePath,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image),
                    )
                  : Image.asset(imagePath, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(price, style: theme.textTheme.bodyMedium),
              if (onAddTap != null)
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
