import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product.dart';

class ProductController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxList<Category> categories = <Category>[].obs;
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final String artisanId;

  ProductController({required this.artisanId});

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadArtisanProducts();
  }

  // Méthode fetchProducts pour la compatibilité
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore
          .collection('products')
          .where('artisanId', isEqualTo: artisanId)
          .get();
      
      products.value = snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] ?? 0.0).toDouble(),
          categoryId: data['categoryId'] ?? '',
          imageUrls: List<String>.from(data['imageUrls'] ?? []),
          createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : DateTime.now(),
          isAvailable: data['isAvailable'] ?? true,
          artisanId: data['artisanId'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des produits: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de récupérer les produits',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Charger toutes les catégories
  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      final QuerySnapshot categorySnapshot = await _firestore
          .collection('categories')
          .orderBy('name')
          .get();

      categories.value = categorySnapshot.docs
          .map((doc) => Category.fromFirestore(doc))
          .toList();
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Impossible de charger les catégories",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.brown,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Charger les produits de l'artisan
  Future<void> loadArtisanProducts() async {
    try {
      isLoading.value = true;
      final QuerySnapshot productSnapshot = await _firestore
          .collection('products')
          .where('artisanId', isEqualTo: artisanId)
          .get();

      products.value = productSnapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Impossible de charger les produits",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.brown,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Ajouter un nouveau produit
  Future<void> addProduct(Product product) async {
    try {
      isLoading.value = true;
      await _firestore.collection('products').add(product.toMap());
      await loadArtisanProducts();
      Get.snackbar(
        "Succès",
        "Produit ajouté avec succès",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.brown,
      );
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Impossible d'ajouter le produit",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.brown,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Modifier un produit existant
  Future<void> updateProduct(String productId, Product product) async {
    try {
      isLoading.value = true;
      await _firestore.collection('products').doc(productId).update(product.toMap());
      await loadArtisanProducts();
      Get.snackbar(
        "Succès",
        "Produit modifié avec succès",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.brown,
      );
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Impossible de modifier le produit",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.brown,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Supprimer un produit
  Future<void> deleteProduct(String productId) async {
    try {
      isLoading.value = true;
      await _firestore.collection('products').doc(productId).delete();
      await loadArtisanProducts();
      Get.snackbar(
        "Succès",
        "Produit supprimé avec succès",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.brown,
      );
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Impossible de supprimer le produit",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.brown,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Obtenir les produits par catégorie
  List<Product> getProductsByCategory(String categoryId) {
    return products.where((product) => product.categoryId == categoryId).toList();
  }

  // Nouvelle méthode pour récupérer tous les produits (pour la partie client)
  Future<void> fetchAllProducts() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore
          .collection('products')
          .get();

      products.value = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erreur lors de la récupération de tous les produits: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de récupérer les produits',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}