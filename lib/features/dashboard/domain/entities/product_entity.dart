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
    final fullImage = rawImage.startsWith('http')
        ? rawImage
        : 'http://192.168.254.10:3000/public/product_images/$rawImage';

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
