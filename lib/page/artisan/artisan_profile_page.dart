import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/product_controller.dart';
import '../../theme/app_theme.dart';
import '../../models/category.dart';
import '../../models/product.dart';

class ArtisanProfilePage extends StatefulWidget {
  const ArtisanProfilePage({Key? key}) : super(key: key);

  @override
  State<ArtisanProfilePage> createState() => _ArtisanProfilePageState();
}

class _ArtisanProfilePageState extends State<ArtisanProfilePage> {
  final CategoryController categoryController = Get.put(CategoryController(), permanent: true);
  final ProductController productController = Get.find<ProductController>();
  final RxString selectedCategoryId = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await categoryController.fetchCategories();
    await productController.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.brown.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Obx(() {
          if (categoryController.isLoading.value || productController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
              ),
            );
          }

          if (categoryController.categories.isEmpty) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
          ),
        ],
      ),
        child: Column(
                  mainAxisSize: MainAxisSize.min,
          children: [
                    Icon(
                      Icons.category_outlined,
                      size: 80,
                      color: AppTheme.primaryBrown.withOpacity(0.5),
                    ),
            const SizedBox(height: 20),
                    Text(
                      'Aucune catégorie disponible',
                      style: TextStyle(
                        color: AppTheme.primaryBrown,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Veuillez contacter l\'administrateur pour ajouter des catégories',
                      style: TextStyle(
                        color: AppTheme.textDark.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                        ),
                      ],
                    ),
              ),
            );
          }

          return Column(
            children: [
              // Liste des catégories
              Container(
                height: 100,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categoryController.categories.length + 1, // +1 pour l'option "Tous"
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Option "Tous"
                      final isSelected = selectedCategoryId.value.isEmpty;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () => selectedCategoryId.value = '',
                    child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryBrown : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                                  color: Colors.brown.withOpacity(0.1),
                                  blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.all_inclusive,
                                  color: isSelected ? Colors.white : AppTheme.primaryBrown,
                                  size: 24,
                      ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tous',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppTheme.primaryBrown,
                                    fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
                        ),
                      );
                    }

                    final category = categoryController.categories[index - 1];
                    final isSelected = selectedCategoryId.value == category.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: InkWell(
                        onTap: () => selectedCategoryId.value = category.id,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryBrown : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.brown.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                children: [
                              Icon(
                                Icons.category_outlined,
                                color: isSelected ? Colors.white : AppTheme.primaryBrown,
                                size: 24,
                  ),
                              const SizedBox(height: 8),
                              Text(
                                category.name,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppTheme.primaryBrown,
                                  fontWeight: FontWeight.bold,
                                ),
                  ),
                ],
              ),
            ),
                      ),
                    );
                  },
        ),
      ),

              // Liste des produits de la catégorie sélectionnée
              Expanded(
                child: Obx(() {
                  final products = selectedCategoryId.value.isEmpty
                      ? productController.products
                      : productController.products.where((p) => p.categoryId == selectedCategoryId.value).toList();

                  if (products.isEmpty) {
                    return Center(
                      child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
                              color: Colors.brown.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
                          mainAxisSize: MainAxisSize.min,
        children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 80,
                              color: AppTheme.primaryBrown.withOpacity(0.5),
                            ),
                            const SizedBox(height: 20),
          Text(
                              selectedCategoryId.value.isEmpty
                                  ? 'Aucun produit trouvé'
                                  : 'Aucun produit dans cette catégorie',
            style: TextStyle(
                                color: AppTheme.primaryBrown,
              fontSize: 18,
              fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              selectedCategoryId.value.isEmpty
                                  ? 'Commencez par ajouter votre premier produit'
                                  : 'Ajoutez des produits à cette catégorie',
                              style: TextStyle(
                                color: AppTheme.textDark.withOpacity(0.7),
                                fontSize: 14,
            ),
          ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => _showAddProductDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Ajouter un produit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBrown,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
        ],
                        ),
      ),
    );
  }

                  return RefreshIndicator(
                    onRefresh: _loadData,
                    color: AppTheme.primaryBrown,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final category = categoryController.categories.firstWhereOrNull((c) => c.id == product.categoryId);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          shadowColor: Colors.brown.withOpacity(0.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  Colors.brown.shade50,
                                ],
                              ),
                            ),
      child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
                                  width: 120,
                                  height: 120,
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
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                product.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.brown.shade100,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${product.price.toStringAsFixed(2)} TND',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.primaryBrown,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.brown.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.brown.shade200,
                                            ),
                                          ),
                                          child: Text(
                                            category?.name ?? 'Non catégorisé',
                style: TextStyle(
                  fontSize: 14,
                                              color: AppTheme.primaryBrown.withOpacity(0.7),
                ),
              ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.brown),
                                              onPressed: () => _showEditProductDialog(context, product),
                                              tooltip: 'Modifier',
                                              style: IconButton.styleFrom(
                                                backgroundColor: Colors.brown.shade50,
                                                padding: const EdgeInsets.all(8),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Confirmer la suppression'),
                                                    content: Text('Voulez-vous vraiment supprimer "${product.name}" ?'),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(16),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.of(context).pop(false),
                                                        child: const Text('Annuler'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () => Navigator.of(context).pop(true),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.red,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                        ),
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
                                              style: IconButton.styleFrom(
                                                backgroundColor: Colors.red.shade50,
                                                padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: AppTheme.primaryBrown,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    // Réutiliser le code de _showAddProductDialog de ArtisanProductManagementPage
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    // Réutiliser le code de _showEditProductDialog de ArtisanProductManagementPage
  }
} 