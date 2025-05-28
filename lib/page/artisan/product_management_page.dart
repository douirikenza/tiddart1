import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/category_controller.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../services/image_service.dart';
import '../../theme/app_theme.dart';

class ProductManagementPage extends StatefulWidget {
  ProductManagementPage({Key? key}) : super(key: key);

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final ProductController productController = Get.find<ProductController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final ImageService imageService = ImageService();

  @override
  void initState() {
    super.initState();
    productController.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Gestion des Produits',
          style: TextStyle(
            color: AppTheme.primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppTheme.primaryBrown),
            onPressed: () => _showCategoryFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
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
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un produit...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.primaryBrown),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (value) {
                  // TODO: Implémenter la recherche
                },
              ),
            ),
          ),
          // Grille de produits
          Expanded(
            child: Obx(
              () => productController.isLoading.value
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBrown),
                      ),
                    )
                  : productController.products.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: AppTheme.primaryBrown.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun produit trouvé',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppTheme.textDark.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () => _showAddProductDialog(context),
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter un produit'),
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
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: productController.products.length,
                          itemBuilder: (context, index) {
                            final product = productController.products[index];
                            return ProductCard(
                              product: product,
                              imageService: imageService,
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: AppTheme.primaryBrown,
        child: const Icon(Icons.add, color: Colors.white),
        elevation: 4,
      ),
    );
  }

  void _showCategoryFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Filtrer par Catégorie',
          style: TextStyle(
            color: AppTheme.primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(
            () => ListView.builder(
              shrinkWrap: true,
              itemCount: categoryController.categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildFilterTile(
                    'Toutes les catégories',
                    Icons.category,
                    () {
                      productController.fetchProducts();
                      Get.back();
                    },
                  );
                }
                final category = categoryController.categories[index - 1];
                return _buildFilterTile(
                  category.name,
                  Icons.folder,
                  () {
                    productController.fetchProducts();
                    Get.back();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBrown),
      title: Text(title),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      hoverColor: AppTheme.primaryBrown.withOpacity(0.1),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    // Réinitialisation à chaque ouverture
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    String? selectedCategoryId;
    final RxList<dynamic> selectedImages = <dynamic>[].obs;

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
              // En-tête
              Text(
                'Ajouter un produit',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBrown,
                ),
              ),
              const SizedBox(height: 24),
              // Formulaire
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Champ Nom
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
                          prefixIcon: Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryBrown),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Champ Description
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
                      const SizedBox(height: 16),
                      // Champ Prix
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Prix',
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
                          prefixIcon: Icon(Icons.attach_money, color: AppTheme.primaryBrown),
                          suffixText: 'TND',
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Sélecteur de catégorie
                      Obx(
                        () => categoryController.isLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : categoryController.categories.isEmpty
                                ? Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.orange,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.orange,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Aucune catégorie disponible. Veuillez contacter l\'admin pour en créer.',
                                            style: TextStyle(
                                              color: Colors.orange.shade900,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : DropdownButtonFormField<String>(
                                    value: selectedCategoryId,
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: null,
                                        child: Text(
                                          'Sélectionner une catégorie',
                                          style: TextStyle(
                                            color: AppTheme.textDark.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                      ...categoryController.categories.map((Category category) {
                                        return DropdownMenuItem(
                                          value: category.id,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.category_outlined,
                                                color: AppTheme.primaryBrown,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(category.name),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (String? value) {
                                      selectedCategoryId = value;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Catégorie',
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
                      ),
                      const SizedBox(height: 24),
                      // Section des images
                      Text(
                        'Images du produit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(() => selectedImages.isNotEmpty
                          ? Container(
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppTheme.primaryBrown.withOpacity(0.3),
                                  style: BorderStyle.solid,
                                  width: 1,
                                ),
                              ),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: selectedImages.length,
                                padding: const EdgeInsets.all(8),
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: (selectedImages[index].startsWith('data:image'))
                                                ? MemoryImage(base64Decode(selectedImages[index].split(',').last))
                                                : NetworkImage(selectedImages[index]) as ImageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 0,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.close, size: 20, color: Colors.red),
                                            onPressed: () => selectedImages.removeAt(index),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 24,
                                              minHeight: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            )
                          : Container(
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppTheme.primaryBrown.withOpacity(0.3),
                                  style: BorderStyle.solid,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 40,
                                      color: AppTheme.primaryBrown.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Aucune image sélectionnée',
                                      style: TextStyle(
                                        color: AppTheme.textDark.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await imageService.showImagePickerDialog(
                            context,
                            (dynamic image) {
                              selectedImages.add(image);
                            },
                          );
                        },
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Ajouter des images'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBrown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Boutons d'action
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
                      if (nameController.text.isNotEmpty &&
                          priceController.text.isNotEmpty &&
                          selectedCategoryId != null &&
                          selectedImages.isNotEmpty) {
                        try {
                          await productController.addProduct(Product(
                            id: '', // L'ID sera généré par Firestore
                              name: nameController.text,
                              description: descriptionController.text,
                            price: double.tryParse(priceController.text) ?? 0.0,
                            categoryId: selectedCategoryId!, // Utilisation de ! car on a vérifié que ce n'est pas null
                            imageUrls: [], // À implémenter : upload d'images
                            createdAt: DateTime.now(),
                            isAvailable: true,
                            artisanId: productController.artisanId,
                          ));
                            Get.back();
                            Get.snackbar(
                              'Succès',
                              'Produit ajouté avec succès',
                              backgroundColor: Colors.green.shade100,
                              colorText: Colors.green.shade800,
                              snackPosition: SnackPosition.TOP,
                            );
                        } catch (e) {
                          Get.snackbar(
                            'Erreur',
                            'Une erreur est survenue lors de l\'ajout du produit',
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade800,
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      } else {
                        Get.snackbar(
                          'Attention',
                          'Veuillez remplir tous les champs obligatoires',
                          backgroundColor: Colors.orange.shade100,
                          colorText: Colors.orange.shade900,
                          snackPosition: SnackPosition.TOP,
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

class ProductCard extends StatelessWidget {
  final Product product;
  final ImageService imageService;
  late final ProductController productController;

  ProductCard({
    Key? key,
    required this.product,
    required this.imageService,
  }) : super(key: key) {
    productController = Get.find<ProductController>();
  }

  @override
  Widget build(BuildContext context) {
    final CategoryController categoryController = Get.find<CategoryController>();
    final category = categoryController.categories
        .firstWhereOrNull((c) => c.id == product.categoryId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(
              children: [
                if (product.imageUrls.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrls.first,
                      width: 80,
                      height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                          fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      const SizedBox(height: 4),
                            Text(
                        'Catégorie: ${category?.name ?? 'Non catégorisé'}',
                              style: TextStyle(
                          color: Colors.grey[600],
                              ),
                            ),
                      const SizedBox(height: 4),
                            Text(
                        '${product.price.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ],
                              ),
                            ),
                            IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditProductDialog(context, product),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmationDialog(context, product),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final nameController = TextEditingController(text: product.name);
    final descriptionController = TextEditingController(text: product.description);
    final priceController = TextEditingController(text: product.price.toString());
    final Rx<String> selectedCategoryId = Rx<String>(product.categoryId);
    final RxList<dynamic> selectedImages = RxList<dynamic>.from(product.imageUrls);
    final ImageService imageService = ImageService();
    final CategoryController categoryController = Get.find<CategoryController>();
    final RxBool isLoading = false.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Modifier le produit'),
        content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du produit',
                  border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                decoration: const InputDecoration(
                          labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: priceController,
                decoration: const InputDecoration(
                          labelText: 'Prix',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<String>(
                    value: selectedCategoryId.value,
                    decoration: const InputDecoration(
                                  labelText: 'Catégorie',
                      border: OutlineInputBorder(),
                    ),
                    items: categoryController.categories
                        .map((category) => DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedCategoryId.value = value;
                      }
                    },
                  )),
                                  ],
                                ),
                              ),
        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
            child: const Text('Annuler'),
                            ),
          Obx(() => isLoading.value
              ? const CircularProgressIndicator()
              : TextButton(
                            onPressed: () async {
                              if (nameController.text.isEmpty) {
                                Get.snackbar(
                                  'Attention',
                                  'Le nom du produit est obligatoire',
                                  backgroundColor: Colors.orange.shade100,
                                  colorText: Colors.orange.shade900,
                                  snackPosition: SnackPosition.TOP,
                                );
                                return;
                              }

                              isLoading.value = true;
                    await productController.updateProduct(
                      product.id,
                      Product(
                                id: product.id,
                                name: nameController.text,
                                description: descriptionController.text,
                        price: double.tryParse(priceController.text) ?? 0.0,
                        categoryId: selectedCategoryId.value,
                        imageUrls: product.imageUrls,
                        createdAt: product.createdAt,
                        isAvailable: product.isAvailable,
                        artisanId: productController.artisanId,
                      ),
                              );
                              isLoading.value = false;
                              Get.back();
                              Get.snackbar(
                                'Succès',
                                'Produit modifié avec succès',
                                backgroundColor: Colors.green.shade100,
                                colorText: Colors.green.shade800,
                                snackPosition: SnackPosition.TOP,
                              );
                            },
                            child: const Text('Enregistrer'),
                )),
          ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Product product) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer le produit "${product.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await productController.deleteProduct(product.id);
              Get.back();
              Get.snackbar(
                'Succès',
                'Produit supprimé avec succès',
                backgroundColor: Colors.green.shade100,
                colorText: Colors.green.shade800,
                snackPosition: SnackPosition.TOP,
              );
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}         