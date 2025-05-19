class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final List<String> imageUrls;
  final DateTime createdAt;
  final bool isAvailable;
  final String artisanId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.imageUrls,
    required this.createdAt,
    required this.isAvailable,
    required this.artisanId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      imageUrls: List<String>.from(json['imageUrls'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isAvailable: json['isAvailable'] as bool,
      artisanId: json['artisanId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(),
      'isAvailable': isAvailable,
      'artisanId': artisanId,
    };
  }
} 