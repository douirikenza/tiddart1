import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../auth_controller.dart';

class CategoryProductsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategoryId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final QuerySnapshot snapshot = await _firestore
          .collection('categories')
          .orderBy('name')
          .get();
      
      categories.value = [
        {
          'id': 'all',
          'name': 'Tous',
        },
        ...snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>
          };
        }).toList(),
      ];

      if (categories.isNotEmpty) {
        selectedCategoryId.value = categories[0]['id'];
        await fetchProductsByCategory(categories[0]['id']);
      }
    } catch (e) {
      print("Erreur lors de la récupération des catégories: $e");
      Get.snackbar(
        'Erreur',
        'Impossible de charger les catégories',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.brown,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProductsByCategory(String categoryId) async {
    try {
      isLoading.value = true;
      selectedCategoryId.value = categoryId;

      final String artisanId = Get.find<AuthController>().userId ?? '';
      print("Fetching products for category: $categoryId and artisan: $artisanId");

      Query query = _firestore.collection('products').where('artisanId', isEqualTo: artisanId);
      
      if (categoryId != 'all') {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      final QuerySnapshot snapshot = await query.get();
      print("Nombre de produits trouvés: ${snapshot.docs.length}");

      products.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print("Produit trouvé: ${data['name']} - Catégorie: ${data['categoryId']} - Artisan: ${data['artisanId']}");
        
        DateTime createdAt;
        if (data['createdAt'] is Timestamp) {
          createdAt = (data['createdAt'] as Timestamp).toDate();
        } else if (data['createdAt'] is String) {
          createdAt = DateTime.tryParse(data['createdAt']) ?? DateTime.now();
        } else {
          createdAt = DateTime.now();
        }

        return Product(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] as num).toDouble(),
          categoryId: data['categoryId'] ?? '',
          imageUrls: List<String>.from(data['imageUrls'] ?? []),
          createdAt: createdAt,
          isAvailable: data['isAvailable'] ?? true,
          artisanId: data['artisanId'] ?? '',
        );
      }).toList();

      print("Produits chargés: ${products.length}");
    } catch (e) {
      print("Erreur lors de la récupération des produits: $e");
      Get.snackbar(
        'Erreur',
        'Impossible de charger les produits',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.brown,
      );
    } finally {
      isLoading.value = false;
    }
  }
} 