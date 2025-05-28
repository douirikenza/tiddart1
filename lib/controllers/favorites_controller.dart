import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';

class FavoritesController extends GetxController {
  // Liste observable des produits favoris
  var favorites = <ProductModel>[].obs;

  bool isFavorite(ProductModel product) {
    return favorites.any((p) => p.id == product.id);
  }

  void addToFavorites(ProductModel product) {
    // Évite les doublons
    if (!favorites.any((p) => p.id == product.id)) {
      favorites.add(product);
      Get.snackbar(
        'Favoris',
        '${product.name} a été ajouté aux favoris.',
        backgroundColor: AppTheme.surfaceLight.withOpacity(0.95),
        colorText: AppTheme.primaryBrown,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        duration: const Duration(seconds: 3),
        boxShadows: AppTheme.defaultShadow,
      );
    }
  }

  void removeFromFavorites(ProductModel product) {
    favorites.removeWhere((p) => p.id == product.id);
    Get.snackbar(
      'Favoris',
      'Produit retiré des favoris.',
      backgroundColor: AppTheme.surfaceLight.withOpacity(0.95),
      colorText: AppTheme.primaryBrown,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
      boxShadows: AppTheme.defaultShadow,
    );
  }
}
