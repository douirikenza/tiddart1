import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiddart/controllers/auth_controller.dart';
import '../models/product.dart';

class ProductController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts({String? categoryId}) async {
    try {
      isLoading.value = true;
      final AuthController authController = Get.find<AuthController>();
      final artisanId = authController.userId;

      if (artisanId == null) {
        Get.snackbar('Erreur', 'Artisan ID not available');
        return;
      }

      Query query = _firestore.collection('products').where('artisanId', isEqualTo: artisanId);
      
      if (categoryId != null) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      final QuerySnapshot snapshot = await query.get();
      products.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product.fromJson({'id': doc.id, ...data});
      }).toList();
    } catch (e) {
      print('Erreur lors du chargement des produits: $e');
      Get.snackbar('Erreur', 'Impossible de charger les produits');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required List<String> imageUrls,
  }) async {
     final AuthController authController = Get.find<AuthController>(); 

    final artisanId = authController.userId;  


    // Check if ArtisanId exist or null
    if (artisanId == null) {
      Get.snackbar('Erreur', 'Artisan ID not available');
      return;
    }
    try {
      isLoading.value = true;
      final docRef = await _firestore.collection('products').add({
        'name': name,
        'description': description,
        'price': price,
        'categoryId': categoryId,
        'imageUrls': imageUrls,
        'createdAt': DateTime.now().toIso8601String(),
        'isAvailable': true,
        'artisanId': artisanId,
      });

      final newProduct = Product(
        id: docRef.id,
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        imageUrls: imageUrls,
        createdAt: DateTime.now(),
        isAvailable: true,
        artisanId: artisanId,
      );

      products.add(newProduct);
      Get.snackbar('Succès', 'Produit ajouté avec succès');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'ajouter le produit');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required List<String> imageUrls,
  }) async {
    try {
      isLoading.value = true;
      final AuthController authController = Get.find<AuthController>();
      final artisanId = authController.userId;

      if (artisanId == null) {
        Get.snackbar('Erreur', 'Artisan ID not available');
        return;
      }

      // Mettre à jour dans Firestore
      await _firestore.collection('products').doc(id).update({
        'name': name,
        'description': description,
        'price': price,
        'categoryId': categoryId,
        'imageUrls': imageUrls,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Mettre à jour dans la liste locale
      final index = products.indexWhere((p) => p.id == id);
      if (index != -1) {
        final updatedProduct = Product(
          id: id,
          name: name,
          description: description,
          price: price,
          categoryId: categoryId,
          imageUrls: imageUrls,
          createdAt: products[index].createdAt,
          isAvailable: products[index].isAvailable,
          artisanId: artisanId,
        );
        products[index] = updatedProduct;
      }

      Get.snackbar('Succès', 'Produit mis à jour avec succès');
    } catch (e) {
      print('Erreur lors de la mise à jour du produit: $e');
      Get.snackbar('Erreur', 'Impossible de mettre à jour le produit');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      isLoading.value = true;
      await _firestore.collection('products').doc(productId).delete();
      products.removeWhere((p) => p.id == productId);
      Get.snackbar('Succès', 'Produit supprimé avec succès');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer le produit');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleProductAvailability(String productId, bool isAvailable) async {
    try {
      isLoading.value = true;
      await _firestore.collection('products').doc(productId).update({
        'isAvailable': isAvailable,
      });
      final index = products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final updatedProduct = Product(
          id: products[index].id,
          name: products[index].name,
          description: products[index].description,
          price: products[index].price,
          categoryId: products[index].categoryId,
          imageUrls: products[index].imageUrls,
          createdAt: products[index].createdAt,
          isAvailable: isAvailable,
          artisanId: products[index].artisanId,
        );
        products[index] = updatedProduct;
      }
      Get.snackbar('Succès', 'Disponibilité du produit mise à jour');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour la disponibilité');
    } finally {
      isLoading.value = false;
    }
  }
  }