class Product {
  final String id;
  final String name;
  final String image;
  final int price;

  const Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'price': price,
  };

  // Create Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['_id'] ?? json['id'],
    name: json['name'],
    image: json['image'],
    price: json['price'],
  );
}
