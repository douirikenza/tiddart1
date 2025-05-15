class ProductModel {
  final String id;
  final String name;
  final String price;
  final String image;
  final String description;
  final String artisan;
  final String category; // ✅ AJOUTÉ

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    required this.artisan,
    required this.category, // ✅ AJOU
  });

  // Convertir une Map (ex: venant de Firestore) en ProductModel
  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductModel(
      id: documentId,
      name: map['name'] ?? '',
      price: map['price'] ?? '',
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      artisan: map['artisan'] ?? '',
      category: map['category'] ?? '', // ✅ Ajouté
      
    );
  }

  // Convertir un ProductModel en Map (ex: pour envoyer à Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'description': description,
      'artisan': artisan,
      'category': category, // ✅ Ajouté
    };
  }
}
