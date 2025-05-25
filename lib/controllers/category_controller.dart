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
    print('CategoryController initialisé !');
    _firestore.collection('categories').snapshots().listen((snapshot) {
      print('Catégories Firestore: \\${snapshot.docs.length}');
      for (var doc in snapshot.docs) {
        print('Catégorie: \\${doc.data()}');
      }
      categories.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Category.fromJson({
          'id'         : doc.id,
          'name'       : data['name']        as String?,
          'description': data['description'] as String?,
          'imageUrl'   : data['image']       as String?,
          'createdAt'  : data['createdAt'],
        });
      }).toList();
    });
  }

  Future<void> addCategory(String name, String description, String imageUrl) async {
    try {
      isLoading.value = true;
      final docRef = await _firestore.collection('categories').add({
        'nom': name,
        'description': description,
        'image': imageUrl,
        'createdAt': DateTime.now().toIso8601String(),
      });

      final newCategory = Category(
        id: docRef.id,
        name: name,
        description: description,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );
       print('category data: ${newCategory.toJson()}');
      categories.add(newCategory);
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