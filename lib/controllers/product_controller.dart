import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Charger tous les produits au démarrage
    loadAllProducts();
  }

  // Charger tous les produits
  Future<void> loadAllProducts() async {
    try {
      isLoading.value = true;
      final QuerySnapshot productsSnapshot = await _firestore.collection('products').get();
      
      products.value = productsSnapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les produits: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Charger les produits par catégorie
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      isLoading.value = true;
      final QuerySnapshot productsSnapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .get();
      
      return productsSnapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les produits: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      );
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // Obtenir un produit par son ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final DocumentSnapshot productDoc = await _firestore
          .collection('products')
          .doc(productId)
          .get();
      
      if (productDoc.exists) {
        return ProductModel.fromMap(
          productDoc.data() as Map<String, dynamic>,
          productDoc.id,
        );
      }
      return null;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger le produit: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      );
      return null;
    }
  }
} 