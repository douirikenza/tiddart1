import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCategoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final QuerySnapshot snapshot = await _firestore.collection('categories').get();
      categories.value = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>
        };
      }).toList();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les catégories');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCategory(String name, String description) async {
    try {
      isLoading.value = true;
      await _firestore.collection('categories').add({
        'name': name,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await fetchCategories();
      Get.snackbar('Succès', 'Catégorie ajoutée avec succès');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'ajouter la catégorie');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCategory(String id, String name, String description) async {
    try {
      isLoading.value = true;
      await _firestore.collection('categories').doc(id).update({
        'name': name,
        'description': description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await fetchCategories();
      Get.snackbar('Succès', 'Catégorie mise à jour avec succès');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour la catégorie');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      isLoading.value = true;
      await _firestore.collection('categories').doc(id).delete();
      await fetchCategories();
      Get.snackbar('Succès', 'Catégorie supprimée avec succès');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer la catégorie');
    } finally {
      isLoading.value = false;
    }
  }
} 