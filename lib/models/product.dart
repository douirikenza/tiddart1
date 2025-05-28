import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_model.dart';

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

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    DateTime createdAt;
    final createdAtField = data['createdAt'];
    if (createdAtField is Timestamp) {
      createdAt = createdAtField.toDate();
    } else if (createdAtField is String) {
      createdAt = DateTime.tryParse(createdAtField) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      categoryId: data['categoryId'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      createdAt: createdAt,
      isAvailable: data['isAvailable'] ?? true,
      artisanId: data['artisanId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'imageUrls': imageUrls,
      'createdAt': createdAt,
      'isAvailable': isAvailable,
      'artisanId': artisanId,
    };
  }

  ProductModel toProductModel() {
    return ProductModel(
      id: id,
      name: name,
      price: '${price.toStringAsFixed(2)} TND',
      image: imageUrls.isNotEmpty ? imageUrls[0] : '',
      description: description,
      artisan: artisanId,
      category: categoryId,
    );
  }
} 