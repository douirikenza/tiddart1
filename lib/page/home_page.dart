import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiddart/routes/app_routes.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/product_controller.dart';
import '../theme/app_theme.dart';
import 'product_details_page.dart';
import 'promotions_page.dart';
import 'favorites_page.dart';
import '../controllers/cart_controller.dart';
import '../models/cart_item_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CategoryController categoryController = Get.put(CategoryController(), permanent: true);
  final ProductController productController = Get.find<ProductController>();
  final FavoritesController favoritesController = Get.find();
  final AuthController authController = Get.find();
  final TextEditingController _searchController = TextEditingController();
  final RxString selectedCategoryId = ''.obs;
  final RxList<Product> filteredProducts = <Product>[].obs;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    _loadData();
  }

  Future<void> _loadData() async {
    await categoryController.fetchCategories();
    await productController.fetchAllProducts();
    _applyFilters();
  }

  void _applyFilters() {
    String query = _searchController.text.toLowerCase();
    List<Product> products = productController.products;
    
    if (selectedCategoryId.value.isNotEmpty) {
      products = products.where((product) => product.categoryId == selectedCategoryId.value).toList();
    }
    
    if (query.isNotEmpty) {
      products = products.where((product) {
        return product.name.toLowerCase().contains(query) ||
               product.description.toLowerCase().contains(query);
      }).toList();
    }
    
    filteredProducts.value = products;
  }

  void _onCategorySelected(String categoryId) {
    selectedCategoryId.value = categoryId;
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Tiddart',
          style: TextStyle(
            color: AppTheme.primaryBrown,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: AppTheme.primaryBrown),
            onPressed: () => Get.to(() => FavoritesPage()),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: AppTheme.primaryBrown),
            onPressed: () => Get.toNamed(AppRoutes.cart),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.primaryBrown,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un produit...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBrown),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  if (categoryController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('Tout'),
                            selected: selectedCategoryId.value.isEmpty,
                            onSelected: (_) => _onCategorySelected(''),
                            selectedColor: AppTheme.primaryBrown,
                            backgroundColor: AppTheme.surfaceLight,
                            labelStyle: TextStyle(
                              color: selectedCategoryId.value.isEmpty ? Colors.white : AppTheme.textDark,
                              fontWeight: selectedCategoryId.value.isEmpty ? FontWeight.bold : FontWeight.normal,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: BorderSide(
                                color: selectedCategoryId.value.isEmpty ? Colors.transparent : AppTheme.primaryBrown.withOpacity(0.2),
                              ),
                            ),
                            elevation: selectedCategoryId.value.isEmpty ? 2 : 0,
                            pressElevation: 2,
                          ),
                        ),
                        ...categoryController.categories.map((category) {
                          final isSelected = selectedCategoryId.value == category.id;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FilterChip(
                              label: Text(category.name),
                              selected: isSelected,
                              onSelected: (_) => _onCategorySelected(category.id),
                              selectedColor: AppTheme.primaryBrown,
                              backgroundColor: AppTheme.surfaceLight,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textDark,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                                side: BorderSide(
                                  color: isSelected ? Colors.transparent : AppTheme.primaryBrown.withOpacity(0.2),
                                ),
                              ),
                              elevation: isSelected ? 2 : 0,
                              pressElevation: 2,
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  if (productController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (filteredProducts.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucun produit trouvé',
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredProducts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return GestureDetector(
                        onTap: () => Get.to(() => ProductDetailsPage(product: product.toProductModel())),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppTheme.defaultShadow,
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                        image: product.imageUrls.isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(product.imageUrls[0]),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: product.imageUrls.isEmpty
                                          ? const Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${product.price.toStringAsFixed(2)} TND',
                                          style: TextStyle(
                                            color: AppTheme.primaryBrown,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Obx(() => IconButton(
                                          icon: Icon(
                                            favoritesController.isFavorite(product.toProductModel())
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: favoritesController.isFavorite(product.toProductModel())
                                                ? Colors.red
                                                : AppTheme.primaryBrown,
                                          ),
                                          onPressed: () {
                                            if (favoritesController.isFavorite(product.toProductModel())) {
                                              favoritesController.removeFromFavorites(product.toProductModel());
                                            } else {
                                              favoritesController.addToFavorites(product.toProductModel());
                                            }
                                          },
                                        ),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: const Icon(Icons.shopping_cart_outlined, color: AppTheme.primaryBrown),
                                      onPressed: () {
                                        final cartController = Get.find<CartController>();
                                        cartController.addToCart(CartItem(product: product.toProductModel(), quantity: 1));
                                        Get.snackbar(
                                          'Ajouté au panier',
                                          '${product.name} a été ajouté au panier.',
                                          backgroundColor: AppTheme.surfaceLight.withOpacity(0.95),
                                          colorText: AppTheme.primaryBrown,
                                          snackPosition: SnackPosition.BOTTOM,
                                          margin: const EdgeInsets.all(16),
                                          borderRadius: 10,
                                          duration: const Duration(seconds: 2),
                                          boxShadows: AppTheme.defaultShadow,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
