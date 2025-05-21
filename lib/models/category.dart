class Category {
  final String id;
  final String nom;
  final String description;
  String? image;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.nom,
    required this.description,
    this.image,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String,
      image: json['image'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'description': description,
      'image': image,
      'createdAt': createdAt.toIso8601String(),
    };
  }
} 