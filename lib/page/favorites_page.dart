import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/favorites_controller.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';
import 'product_details_page.dart';

class FavoritesPage extends StatelessWidget {
  FavoritesPage({super.key});

  final FavoritesController favoritesController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Mes Favoris',
          style: AppTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() => favoritesController.favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: AppTheme.primaryBrown.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Aucun produit dans les favoris",
                    style: AppTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryBrown.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: favoritesController.favorites.length,
              itemBuilder: (context, index) {
                final product = favoritesController.favorites[index];
                return GestureDetector(
                  onTap: () => Get.to(() => ProductDetailsPage(product: product)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBrown.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.asset(
                                product.image,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => favoritesController.removeFromFavorites(product.id),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceLight,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: AppTheme.textTheme.titleMedium?.copyWith(
                                  color: AppTheme.primaryBrown,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.price,
                                style: AppTheme.textTheme.titleMedium?.copyWith(
                                  color: AppTheme.accentGold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
    );
  }
}
