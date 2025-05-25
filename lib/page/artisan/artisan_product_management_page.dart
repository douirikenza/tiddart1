import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/product_controller.dart';
import '../../theme/app_theme.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../services/image_service.dart';

class ArtisanProductManagementPage extends StatefulWidget {
  ArtisanProductManagementPage({Key? key}) : super(key: key);

  @override
  State<ArtisanProductManagementPage> createState() => _ArtisanProductManagementPageState();
}

class _ArtisanProductManagementPageState extends State<ArtisanProductManagementPage> {
  final CategoryController categoryController = Get.put(CategoryController(), permanent: true);
  final ProductController productController = Get.find<ProductController>();
  final ImageService imageService = ImageService();

  @override
  void initState() {
    super.initState();
    productController.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes produits'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.brown),
            onPressed: () => _showAddProductDialog(context),
            tooltip: 'Ajouter un produit',
          ),
        ],
      ),
      body: Obx(() {
        if (productController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (productController.products.isEmpty) {
          return Center(
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
                    color: AppTheme.primaryBrown,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _showAddProductDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un produit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryBrown,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: productController.products.length,
          itemBuilder: (context, index) {
            final product = productController.products[index];
            final category = categoryController.categories.firstWhereOrNull((c) => c.id == product.categoryId);
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image du produit
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      image: DecorationImage(
                        image: (product.imageUrls.isNotEmpty)
                            ? NetworkImage(product.imageUrls.first) as ImageProvider
                            : const AssetImage('assets/icons/placeholder.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
                            category?.name ?? 'Non catégorisé',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.primaryBrown.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${product.price.toStringAsFixed(2)} TND',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.brown),
                                onPressed: () => _showEditProductDialog(context, product),
                                tooltip: 'Modifier',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmer la suppression'),
                                      content: Text('Voulez-vous vraiment supprimer "${product.name}" ?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Annuler'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          child: const Text('Supprimer'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    productController.deleteProduct(product.id);
                                  }
                                },
                                tooltip: 'Supprimer',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    String? selectedCategoryId;
    final RxList<dynamic> selectedImages = <dynamic>[].obs;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.brown.shade50,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.add_box_rounded, color: AppTheme.primaryBrown, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      'Ajouter un produit',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBrown,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(color: Colors.brown.shade100, thickness: 1),
                const SizedBox(height: 18),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom du produit',
                    hintText: 'Ex : Tapis berbère',
                    labelStyle: TextStyle(color: AppTheme.primaryBrown),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.primaryBrown.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.primaryBrown, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.brown.shade50,
                    prefixIcon: Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryBrown),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Décrivez le produit...',
                    labelStyle: TextStyle(color: AppTheme.primaryBrown),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.primaryBrown.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.primaryBrown, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.brown.shade50,
                    prefixIcon: Icon(Icons.description_outlined, color: AppTheme.primaryBrown),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Prix (TND)',
                    hintText: 'Ex : 120',
                    labelStyle: TextStyle(color: AppTheme.primaryBrown),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.primaryBrown.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.primaryBrown, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.brown.shade50,
                    prefixIcon: Icon(Icons.attach_money, color: AppTheme.primaryBrown),
                  ),
                ),
                const SizedBox(height: 14),
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
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                filled: true,
                                fillColor: Colors.brown.shade50,
                              ),
                            ),
                ),
                const SizedBox(height: 18),
                Divider(color: Colors.brown.shade100, thickness: 1),
                const SizedBox(height: 12),
                Text(
                  'Images du produit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBrown,
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() => selectedImages.isNotEmpty
                    ? Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryBrown.withOpacity(0.2),
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
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: (selectedImages[index] is String && selectedImages[index].startsWith('data:image'))
                                          ? MemoryImage(
                                              UriData.parse(selectedImages[index]).contentAsBytes(),
                                            )
                                          : (selectedImages[index] is String)
                                              ? NetworkImage(selectedImages[index]) as ImageProvider
                                              : const AssetImage('assets/icons/placeholder.png'),
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
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
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryBrown.withOpacity(0.2),
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
                      )
                ),
                const SizedBox(height: 14),
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
                        if (nameController.text.isNotEmpty &&
                            priceController.text.isNotEmpty &&
                            selectedCategoryId != null &&
                            selectedImages.isNotEmpty) {
                          try {
                            final imageUrls = await Future.wait(
                              selectedImages.map((image) => imageService.uploadImage(image, 'products')),
                            );
                            if (imageUrls.every((url) => url != null)) {
                              await productController.addProduct(
                                name: nameController.text,
                                description: descriptionController.text,
                                price: double.parse(priceController.text),
                                categoryId: selectedCategoryId!,
                                imageUrls: imageUrls.cast<String>(),
                              );
                              Navigator.of(context).pop();
                              Future.delayed(const Duration(milliseconds: 300), () {
                                Get.snackbar(
                                  'Succès',
                                  'Produit ajouté avec succès',
                                  backgroundColor: Colors.green.shade100,
                                  colorText: Colors.green.shade800,
                                  snackPosition: SnackPosition.TOP,
                                );
                              });
                            } else {
                              Get.snackbar(
                                'Erreur',
                                'Impossible de télécharger une ou plusieurs images',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red.shade800,
                                snackPosition: SnackPosition.TOP,
                              );
                            }
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
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      child: const Text('Ajouter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final nameController = TextEditingController(text: product.name);
    final descriptionController = TextEditingController(text: product.description);
    final priceController = TextEditingController(text: product.price.toString());
    String? selectedCategoryId = product.categoryId;
    final RxList<dynamic> selectedImages = <dynamic>[].obs;
    selectedImages.addAll(product.imageUrls);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.brown.shade50,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit, color: AppTheme.primaryBrown, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      'Modifier le produit',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBrown,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(color: Colors.brown.shade100, thickness: 1),
                const SizedBox(height: 18),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom du produit',
                    hintText: 'Ex : Tapis berbère',
                    labelStyle: TextStyle(color: AppTheme.primaryBrown),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.primaryBrown.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.primaryBrown, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.brown.shade50,
                    prefixIcon: Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryBrown),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Décrivez le produit...',
                    labelStyle: TextStyle(color: AppTheme.primaryBrown),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.primaryBrown.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.primaryBrown, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.brown.shade50,
                    prefixIcon: Icon(Icons.description_outlined, color: AppTheme.primaryBrown),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Prix (TND)',
                    hintText: 'Ex : 120',
                    labelStyle: TextStyle(color: AppTheme.primaryBrown),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.primaryBrown.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.primaryBrown, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.brown.shade50,
                    prefixIcon: Icon(Icons.attach_money, color: AppTheme.primaryBrown),
                  ),
                ),
                const SizedBox(height: 14),
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
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                filled: true,
                                fillColor: Colors.brown.shade50,
                              ),
                            ),
                ),
                const SizedBox(height: 18),
                Divider(color: Colors.brown.shade100, thickness: 1),
                const SizedBox(height: 12),
                Text(
                  'Images du produit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBrown,
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() => selectedImages.isNotEmpty
                    ? Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryBrown.withOpacity(0.2),
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
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: (selectedImages[index] is String && selectedImages[index].startsWith('data:image'))
                                          ? MemoryImage(
                                              UriData.parse(selectedImages[index]).contentAsBytes(),
                                            )
                                          : (selectedImages[index] is String)
                                              ? NetworkImage(selectedImages[index]) as ImageProvider
                                              : const AssetImage('assets/icons/placeholder.png'),
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
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
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryBrown.withOpacity(0.2),
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
                      )
                ),
                const SizedBox(height: 14),
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
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
                            // Traiter les images
                            List<String> finalImageUrls = [];
                            for (var image in selectedImages) {
                              if (image is String && image.startsWith('http')) {
                                // C'est une URL existante, on la garde
                                finalImageUrls.add(image);
                              } else {
                                // C'est une nouvelle image, on la télécharge
                                final url = await imageService.uploadImage(image, 'products');
                                if (url != null) {
                                  finalImageUrls.add(url);
                                }
                              }
                            }

                            if (finalImageUrls.isNotEmpty) {
                              await productController.updateProduct(
                                id: product.id,
                                name: nameController.text,
                                description: descriptionController.text,
                                price: double.parse(priceController.text),
                                categoryId: selectedCategoryId!,
                                imageUrls: finalImageUrls,
                              );
                              Navigator.of(context).pop();
                              Get.snackbar(
                                'Succès',
                                'Produit modifié avec succès',
                                backgroundColor: Colors.green.shade100,
                                colorText: Colors.green.shade800,
                                snackPosition: SnackPosition.TOP,
                              );
                            } else {
                              Get.snackbar(
                                'Erreur',
                                'Impossible de traiter les images',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red.shade800,
                                snackPosition: SnackPosition.TOP,
                              );
                            }
                          } catch (e) {
                            print('Erreur lors de la modification du produit: $e');
                            Get.snackbar(
                              'Erreur',
                              'Une erreur est survenue lors de la modification du produit',
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
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      child: const Text('Modifier'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 