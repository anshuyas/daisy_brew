class Product {
  final String id;
  final String name;
  final String image;
  final int price;
  final bool isAvailable;
  final String category;

  const Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.isAvailable,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'price': price,
    'isAvailable': isAvailable,
    'category': category,
  };

  // Create Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image'] ?? '';

    String fullImage;
    if (rawImage.startsWith('http') || rawImage.startsWith('assets/')) {
      // Already a full URL or a local asset path — use as-is
      fullImage = rawImage;
    } else if (rawImage.isEmpty) {
      fullImage = 'assets/images/tea_placeholder.png';
    } else {
      // Raw filename from backend — build the full URL
      fullImage = 'http://192.168.254.50:3000/public/product_images/$rawImage';
    }

    return Product(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? 'Unnamed',
      image: fullImage,
      price: json['price'] ?? 0,
      isAvailable: json['isAvailable'] ?? true,
      category: json['category'] ?? 'Uncategorized',
    );
  }
}
