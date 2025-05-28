class Artisan {
  final String id;
  final String nom;
  final String? photoUrl;
  final String? email;
  final String? telephone;

  Artisan({
    required this.id,
    required this.nom,
    this.photoUrl,
    this.email,
    this.telephone,
  });

  factory Artisan.fromMap(String id, Map<String, dynamic> data) {
    return Artisan(
      id: id,
      nom: data['nom'] ?? '',
      photoUrl: data['photoUrl'],
      email: data['email'],
      telephone: data['telephone'],
    );
  }
} 