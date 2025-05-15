import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';
import '../controllers/favorites_controller.dart';
import 'product_details_page.dart';

class PromotionsPage extends StatelessWidget {
  const PromotionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FavoritesController favoritesController = Get.find();

    final List<ProductModel> promotions = [
      ProductModel(
        id: '1',
        name: "Savon naturel",
        price: "8,00 TND",
        image: "assets/savon.jpeg",
        description: "Savon à base d'huile d'olive 100% naturel.",
        artisan: "Artisan Ali",
        category: "Cosmétiques",
      ),
      ProductModel(
        id: '2',
        name: "Huile d'olive bio",
        price: "18,00 TND",
        image: "assets/huile.jpeg",
        description: "Huile d'olive extra vierge, pressée à froid.",
        artisan: "Artisan Fatma",
        category: "Nourriture",
      ),
      ProductModel(
        id: '3',
        name: "Tapis berbère",
        price: "110,00 TND",
        image: "assets/tapis.jpeg",
        description: "Tapis traditionnel fait main.",
        artisan: "Artisan Khaled",
        category: "Décoration",
      ),
      ProductModel(
        id: '4',
        name: "Poterie artisanale",
        price: "45,00 TND",
        image: "assets/poterie.jpeg",
        description: "Poterie traditionnelle peinte à la main.",
        artisan: "Artisan Amira",
        category: "Décoration",
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: ShaderMask(
                shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                child: Text(
                  'Nos Promotions',
                  style: AppTheme.textTheme.displayMedium?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryBrown.withOpacity(0.15),
                          AppTheme.accentGold.withOpacity(0.05),
                          AppTheme.primaryBrown.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                  // Cercles décoratifs
                  Positioned(
                    right: -80,
                    top: -30,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentGold.withOpacity(0.2),
                            AppTheme.primaryBrown.withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -60,
                    bottom: -20,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryBrown.withOpacity(0.15),
                            AppTheme.accentGold.withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Texte promotionnel
                  Positioned(
                    bottom: 80,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryBrown.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Offres Limitées',
                            style: AppTheme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Découvrez notre sélection de produits artisanaux à prix réduits',
                          style: AppTheme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.primaryBrown,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = promotions[index];
                  return Hero(
                    tag: 'promotion_${product.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: GestureDetector(
                        onTap: () => Get.to(() => ProductDetailsPage(product: product)),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryBrown.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: 180,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(24),
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          AppTheme.primaryBrown.withOpacity(0.05),
                                          AppTheme.surfaceLight,
                                        ],
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(24),
                                      ),
                                      child: Image.asset(
                                        product.image,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: () {
                                        final isFavori = favoritesController.favorites.any((p) => p.id == product.id);
                                        if (isFavori) {
                                          favoritesController.removeFromFavorites(product.id);
                                        } else {
                                          favoritesController.addToFavorites(product);
                                        }
                                      },
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
                                        child: Obx(() {
                                          final isFavori = favoritesController.favorites.any((p) => p.id == product.id);
                                          return AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 300),
                                            child: Icon(
                                              isFavori ? Icons.favorite : Icons.favorite_border,
                                              color: isFavori ? Colors.red : AppTheme.primaryBrown,
                                              size: 22,
                                              key: ValueKey(isFavori),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.red.shade600,
                                            Colors.red.shade400,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.local_offer,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '-20%',
                                            style: AppTheme.textTheme.labelLarge?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
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
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          product.price,
                                          style: AppTheme.textTheme.titleSmall?.copyWith(
                                            color: AppTheme.accentGold,
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${(double.parse(product.price.replaceAll(',', '.').replaceAll(' TND', '')) * 0.8).toStringAsFixed(2)} TND',
                                          style: AppTheme.textTheme.titleMedium?.copyWith(
                                            color: AppTheme.primaryBrown,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 16,
                                          color: AppTheme.primaryBrown.withOpacity(0.7),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          product.artisan,
                                          style: AppTheme.textTheme.bodySmall?.copyWith(
                                            color: AppTheme.primaryBrown.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: promotions.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
