import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

class CategorySelectorPage extends StatelessWidget {
  const CategorySelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'title': 'Cosmétiques', 'icon': 'assets/icons/cosmetiques.png', 'route': AppRoutes.cosmetics},
      {'title': 'Nourriture', 'icon': 'assets/icons/food.png', 'route': AppRoutes.food},
      {'title': 'Décoration', 'icon': 'assets/icons/decoration.png', 'route': AppRoutes.decoration},
      {'title': 'Textile', 'icon': 'assets/icons/textile.png', 'route': AppRoutes.textile},
      {'title': 'Accessoires', 'icon': 'assets/icons/accessoires.png', 'route': null}, // En attente
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0D9B5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0D9B5),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Toutes les catégories',
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.brown),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.95,
        ),
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: category['route'] != null
                ? () => Get.toNamed(category['route'])
                : () => _showComingSoon(context),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE2BF91),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(category['icon'], height: 50),
                  const SizedBox(height: 12),
                  Text(
                    category['title'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.brown,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    Get.snackbar(
      "Bientôt disponible",
      "Cette catégorie sera bientôt ajoutée.",
      backgroundColor: const Color(0xFFEAD8C0),
      colorText: Colors.brown,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    );
  }
}
