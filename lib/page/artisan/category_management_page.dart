import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/category_controller.dart';
import '../../models/category.dart';
import '../../services/image_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/loading_overlay.dart';

class CategoryManagementPage extends StatelessWidget {
  final CategoryController controller = Get.put(CategoryController());
  final ImageService imageService = ImageService();

  CategoryManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Gestion des Catégories',
          style: TextStyle(
            color: AppTheme.primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // En-tête avec statistiques
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Total Catégories',
                  '${controller.categories.length}',
                  Icons.category_outlined,
                  AppTheme.primaryBrown,
                ),
                _buildStatCard(
                  'Produits',
                  '25', // À remplacer par le nombre réel
                  Icons.shopping_bag_outlined,
                  Colors.green,
                ),
              ],
            )),
          ),
          // Liste des catégories
          Expanded(
            child: Obx(
              () => controller.isLoading.value
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBrown),
                      ),
                    )
                  : controller.categories.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 64,
                                color: AppTheme.primaryBrown.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune catégorie',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppTheme.textDark.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () => _showAddCategoryDialog(context),
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter une catégorie'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBrown,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.categories.length,
                          itemBuilder: (context, index) {
                            final category = controller.categories[index];
                            return CategoryCard(
                              category: category,
                              imageService: imageService,
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        backgroundColor: AppTheme.primaryBrown,
        child: const Icon(Icons.add, color: Colors.white),
        elevation: 4,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textDark.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final Rx<File?> selectedImage = Rx<File?>(null);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajouter une catégorie',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBrown,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  labelStyle: TextStyle(color: AppTheme.primaryBrown),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppTheme.primaryBrown.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppTheme.primaryBrown, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.category_outlined, color: AppTheme.primaryBrown),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: AppTheme.primaryBrown),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppTheme.primaryBrown.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppTheme.primaryBrown, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.description_outlined, color: AppTheme.primaryBrown),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Image de la catégorie',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBrown,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => selectedImage.value != null
                  ? Stack(
                      children: [
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(selectedImage.value!),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => selectedImage.value = null,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.primaryBrown.withOpacity(0.3),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: AppTheme.primaryBrown.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ajouter une image',
                            style: TextStyle(
                              color: AppTheme.primaryBrown.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await imageService.showImagePickerDialog(
                      context,
                      (File image) {
                        selectedImage.value = image;
                      },
                    );
                  },
                  icon: const Icon(Icons.add_photo_alternate),
                  label: Text(selectedImage.value == null
                      ? 'Sélectionner une image'
                      : 'Changer l\'image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                        color: AppTheme.primaryBrown,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty) {
                        Get.snackbar(
                          'Attention',
                          'Le nom de la catégorie est obligatoire',
                          backgroundColor: Colors.orange.shade100,
                          colorText: Colors.orange.shade900,
                          snackPosition: SnackPosition.TOP,
                        );
                        return;
                      }

                      if (selectedImage.value == null) {
                        Get.snackbar(
                          'Attention',
                          'Veuillez sélectionner une image pour la catégorie',
                          backgroundColor: Colors.orange.shade100,
                          colorText: Colors.orange.shade900,
                          snackPosition: SnackPosition.TOP,
                        );
                        return;
                      }

                      try {
                        // Afficher un indicateur de chargement
                        final loadingOverlay = LoadingOverlay.show(
                          context,
                          'Création de la catégorie en cours...',
                        );

                        final imageUrl = await imageService.uploadImage(
                          selectedImage.value!,
                          'categories',
                        );

                        if (imageUrl != null) {
                          await controller.addCategory(
                            nameController.text,
                            descriptionController.text,
                            imageUrl,
                          );
                          
                          // Fermer l'indicateur de chargement
                          loadingOverlay.dismiss();
                          
                          Get.back();
                          Get.snackbar(
                            'Succès',
                            'Catégorie ajoutée avec succès',
                            backgroundColor: Colors.green.shade100,
                            colorText: Colors.green.shade800,
                            snackPosition: SnackPosition.TOP,
                          );
                        } else {
                          // Fermer l'indicateur de chargement
                          loadingOverlay.dismiss();
                        }
                      } catch (e) {
                        debugPrint('Erreur lors de l\'ajout de la catégorie: $e');
                        Get.snackbar(
                          'Erreur',
                          'Une erreur est survenue lors de l\'ajout de la catégorie',
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.red.shade800,
                          snackPosition: SnackPosition.TOP,
                          duration: const Duration(seconds: 5),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Ajouter'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;
  final ImageService imageService;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.imageService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showEditDialog(context, category),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image de la catégorie
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(category.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '12 produits', // À remplacer par le nombre réel
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Description et actions
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.description,
                        style: TextStyle(
                          color: AppTheme.textDark.withOpacity(0.7),
                          fontSize: 14,
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildActionButton(
                            icon: Icons.edit,
                            label: 'Modifier',
                            color: AppTheme.primaryBrown,
                            onTap: () => _showEditDialog(context, category),
                          ),
                          const SizedBox(width: 16),
                          _buildActionButton(
                            icon: Icons.delete,
                            label: 'Supprimer',
                            color: Colors.red,
                            onTap: () => _showDeleteDialog(context, category.id),
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
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String categoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer la catégorie "${category.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: AppTheme.primaryBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await Get.find<CategoryController>().deleteCategory(categoryId);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Category category) {
    // TODO: Implémenter la modification de catégorie
    Get.snackbar(
      'Info',
      'Fonctionnalité de modification à venir',
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade900,
      snackPosition: SnackPosition.TOP,
    );
  }
} 