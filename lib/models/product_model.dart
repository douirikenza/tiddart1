class ProductModel {
  final String id;
  final String name;
  final String price;  // Format: "8.00 TND"
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
    // Traiter le prix
    String priceStr = map['price']?.toString() ?? '0';
    // Supprimer 'TND' et les espaces s'ils existent
    priceStr = priceStr.replaceAll('TND', '').trim();
    
    // Traitement spécial pour les grands nombres (ex: 1.234,56)
    if (priceStr.contains('.') && priceStr.contains(',')) {
      // Si le point vient avant la virgule, c'est un séparateur de milliers
      if (priceStr.indexOf('.') < priceStr.indexOf(',')) {
        priceStr = priceStr.replaceAll('.', '').replaceAll(',', '.');
      }
    } else {
      // Cas normal : remplacer la virgule par un point
      priceStr = priceStr.replaceAll(',', '.');
    }
    
    // Convertir en double pour normaliser
    double priceValue = double.tryParse(priceStr) ?? 0.0;
    // Reformater avec 2 décimales et TND
    String formattedPrice = '${priceValue.toStringAsFixed(2)} TND';
    
    return ProductModel(
      id: documentId,
      name: map['name'] ?? '',
      price: formattedPrice,
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      artisan: map['artisan'] ?? '',
      category: map['category'] ?? '',
    );
  }

  // Convertir un ProductModel en Map (ex: pour envoyer à Firestore)
  Map<String, dynamic> toMap() {
    // Extraire seulement la valeur numérique du prix
    double priceValue = getPriceAsDouble();
    return {
      'name': name,
      'price': priceValue.toStringAsFixed(2),  // Stocker sans 'TND'
      'image': image,
      'description': description,
      'artisan': artisan,
      'category': category, // ✅ Ajouté
    };
  }

  // Helper method to get price as double
  double getPriceAsDouble() {
    // Supprimer 'TND' et les espaces, puis convertir en double
    String numericPrice = price.replaceAll('TND', '').trim();
    
    // Traitement spécial pour les grands nombres (ex: 1.234,56)
    if (numericPrice.contains('.') && numericPrice.contains(',')) {
      // Si le point vient avant la virgule, c'est un séparateur de milliers
      if (numericPrice.indexOf('.') < numericPrice.indexOf(',')) {
        numericPrice = numericPrice.replaceAll('.', '').replaceAll(',', '.');
      }
    } else {
      // Cas normal : remplacer la virgule par un point
      numericPrice = numericPrice.replaceAll(',', '.');
    }
    
    return double.tryParse(numericPrice) ?? 0.0;
  }

  // Helper method to format price with currency
  String getFormattedPrice() {
    double priceValue = getPriceAsDouble();
    return '${priceValue.toStringAsFixed(2)} TND';
  }
}
