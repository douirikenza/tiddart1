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
    final categoryIdField = json['categoryId'];
    String categoryId;
    if (categoryIdField is String) {
      categoryId = categoryIdField;
    } else if (categoryIdField != null && categoryIdField.runtimeType.toString().contains('DocumentReference')) {
      categoryId = categoryIdField.id;
    } else {
      categoryId = '';
    }
    return Product(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] as num?)?.toDouble() ?? 0.0,
      categoryId: categoryId,
      imageUrls: (json['imageUrls'] is List)
          ? List<String>.from(json['imageUrls'])
          : <String>[],
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      isAvailable: json['isAvailable'] is bool ? json['isAvailable'] as bool : true,
      artisanId: json['artisanId'] as String? ?? '',
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