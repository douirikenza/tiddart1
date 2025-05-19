import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';

class ArtisanProfilePage extends StatelessWidget {
  const ArtisanProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Profil Artisan',
          style: TextStyle(
            color: AppTheme.primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryBrown),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: AppTheme.primaryBrown),
            onPressed: () {
              // TODO: Implémenter la modification du profil
              Get.snackbar(
                'Info',
                'Modification du profil à venir',
                backgroundColor: AppTheme.surfaceLight,
                colorText: AppTheme.primaryBrown,
                borderRadius: 10,
                margin: const EdgeInsets.all(10),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Photo de profil
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryBrown,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBrown.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://via.placeholder.com/120',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrown,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBrown.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Nom de l'artisan
            Text(
              'Mohamed Ali',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBrown,
              ),
            ),
            Text(
              'Artisan Traditionnel',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textDark.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 30),
            // Informations du profil
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildInfoCard(
                    'Informations Personnelles',
                    [
                      _buildInfoRow(Icons.email, 'Email', 'mohamed.ali@email.com'),
                      _buildInfoRow(Icons.phone, 'Téléphone', '+216 XX XXX XXX'),
                      _buildInfoRow(Icons.location_on, 'Adresse', 'Tunis, Tunisie'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard(
                    'Informations Professionnelles',
                    [
                      _buildInfoRow(Icons.work, 'Spécialité', 'Artisanat traditionnel'),
                      _buildInfoRow(Icons.star, 'Expérience', '10 ans'),
                      _buildInfoRow(Icons.category, 'Catégories', '3 catégories'),
                      _buildInfoRow(Icons.shopping_bag, 'Produits', '12 produits'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard(
                    'Statistiques',
                    [
                      _buildInfoRow(Icons.trending_up, 'Ventes totales', '1.2k TND'),
                      _buildInfoRow(Icons.people, 'Clients', '45 clients'),
                      _buildInfoRow(Icons.star_rate, 'Note moyenne', '4.8/5'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBrown,
            ),
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBrown.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryBrown,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textDark.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 