import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

class CategoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('CategoryController initialisé');
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final QuerySnapshot snapshot = await _firestore.collection('categories').get();
      categories.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Category.fromJson({'id': doc.id, ...data});
      }).toList();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les catégories');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCategory(String nom, String description, String? image) async {
    try {
      isLoading.value = true;
      final docRef = await _firestore.collection('categories').add({
        'nom': nom,
        'description': description,
        'image': image,
        'createdAt': DateTime.now().toIso8601String(),
      });

      final newCategory = Category(
        id: docRef.id,
        nom: nom,
        description: description,
        image: image,
        createdAt: DateTime.now(),
      );
      print('category data:  ${newCategory.toJson()}');
      categories.add(newCategory);
      await fetchCategories();
      Get.snackbar('Succès', 'Catégorie ajoutée avec succès');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'ajouter la catégorie');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      isLoading.value = true;
      await _firestore.collection('categories').doc(category.id).update(category.toJson());
      final index = categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        categories[index] = category;
      }
      Get.snackbar('Succès', 'Catégorie mise à jour avec succès');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour la catégorie');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      isLoading.value = true;
      await _firestore.collection('categories').doc(categoryId).delete();
      categories.removeWhere((c) => c.id == categoryId);
      Get.snackbar('Succès', 'Catégorie supprimée avec succès');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer la catégorie');
    } finally {
      isLoading.value = false;
    }
  }
} 