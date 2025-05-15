import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';

class FavoritesController extends GetxController {
  // Liste observable des produits favoris
  var favorites = <ProductModel>[].obs;

  void addToFavorites(ProductModel product) {
    // Évite les doublons
    if (!favorites.any((p) => p.id == product.id)) {
      favorites.add(product);
      Get.snackbar(
        'Favoris',
        '${product.name} a été ajouté aux favoris.',
        backgroundColor: const Color(0xFFFFF6E5),
        colorText: const Color(0xFF4B2706),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void removeFromFavorites(String productId) {
    favorites.removeWhere((p) => p.id == productId);
    Get.snackbar(
      'Favoris',
      'Produit retiré des favoris.',
      backgroundColor: const Color(0xFFFFF6E5),
      colorText: const Color(0xFF4B2706),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
