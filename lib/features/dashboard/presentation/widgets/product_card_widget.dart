import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductCardWidget extends StatelessWidget {
  final String name;
  final String price;
  final String imagePath;
  final VoidCallback? onAddTap;
  final bool isOnline;

  const ProductCardWidget({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
    this.onAddTap,
    this.isOnline = true,
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImage(),
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

  Widget _buildImage() {
    // If offline, always show placeholder per card
    if (!isOnline) {
      return Image.asset(
        'assets/images/tea_placeholder.png',
        fit: BoxFit.cover,
      );
    }

    if (imagePath.isEmpty || imagePath == 'assets/images/tea_placeholder.png') {
      return Image.asset(
        'assets/images/tea_placeholder.png',
        fit: BoxFit.cover,
      );
    }

    if (imagePath.toLowerCase().startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) =>
            Image.asset('assets/images/tea_placeholder.png', fit: BoxFit.cover),
      );
    }

    return Image.asset(imagePath, fit: BoxFit.cover);
  }
}
