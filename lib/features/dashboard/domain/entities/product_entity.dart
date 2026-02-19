class Product {
  final String name;
  final String image;
  final int price;

  const Product({required this.name, required this.image, required this.price});

  Map<String, dynamic> toJson() => {
    'name': name,
    'image': image,
    'price': price,
  };

  // Create Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) =>
      Product(name: json['name'], image: json['image'], price: json['price']);
}
