import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiddart/routes/app_routes.dart';
import '../models/product_model.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import 'product_details_page.dart';
import 'promotions_page.dart';
import 'favorites_page.dart'; // ✅ Corrigé ici
import '../controllers/cart_controller.dart';
import '../models/cart_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<String> categories = <String>[].obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;
  String selectedCategory = 'Tout';
  final FavoritesController favoritesController = Get.find();
  final AuthController authController = Get.find();
  final TextEditingController _searchController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    fetchCategories();
    fetchProducts();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final QuerySnapshot snapshot = await _firestore
          .collection('categories')
          .orderBy('name')
          .get();
      
      categories.value = [
        'Tout',
        ...snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['name'] as String;
        }).toList(),
      ];
    } catch (e) {
      print("Erreur lors de la récupération des catégories: $e");
      Get.snackbar(
        'Erreur',
        'Impossible de charger les catégories',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.brown,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      Query query = _firestore.collection('products');
      
      if (selectedCategory != 'Tout') {
        query = query.where('category', isEqualTo: selectedCategory);
      }

      final QuerySnapshot snapshot = await query.get();
      final List<ProductModel> fetchedProducts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('Product data: $data'); // Debug print
        return ProductModel.fromMap(data, doc.id);
      }).toList();

      print('Fetched products count: ${fetchedProducts.length}'); // Debug print
      products.value = fetchedProducts;
    } catch (e) {
      print("Erreur lors de la récupération des produits: $e");
      Get.snackbar(
        'Erreur',
        'Impossible de charger les produits',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.brown,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilters() {
    String query = _searchController.text.toLowerCase();
    if (query.isEmpty && selectedCategory == 'Tout') {
      fetchProducts();
    } else {
      setState(() {
        products.value = products.where((product) {
          final matchCategory = selectedCategory == 'Tout' || product.category == selectedCategory;
          final matchSearch = product.name.toLowerCase().contains(query) ||
              product.description.toLowerCase().contains(query);
          return matchCategory && matchSearch;
        }).toList();
      });
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
    fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCategoriesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFCEEDB),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => ListView(
        padding: const EdgeInsets.all(20),
        children: categories.map((cat) {
          return ListTile(
            title: Text(cat, style: const TextStyle(color: Colors.brown)),
            leading: const Icon(Icons.category, color: Colors.brown),
            onTap: () {
              Navigator.pop(context);
              _onCategorySelected(cat);
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.menu, color: AppTheme.primaryBrown),
            onPressed: () => _showCategoriesModal(context),
          ),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
          child: Text(
            'Tiddart',
            style: AppTheme.textTheme.displayMedium,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => Get.to(() => FavoritesPage()),
            ),
          ),
          Obx(() => authController.firebaseUser.value != null
            ? PopupMenuButton(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        'Déconnexion',
                        style: TextStyle(
                          color: AppTheme.primaryBrown,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        authController.logout();
                      },
                    ),
                  ),
                ],
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.accentGold,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Obx(() {
                      final user = authController.firebaseUser.value;
                      return user?.photoURL != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                user!.photoURL!,
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    color: AppTheme.primaryBrown,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.person,
                              color: AppTheme.primaryBrown,
                            );
                    }),
                  ),
                ),
              )
            : Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.person_outline, color: AppTheme.primaryBrown),
                  onPressed: () => Get.toNamed(AppRoutes.login),
                ),
              ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundLight,
              AppTheme.surfaceLight,
              AppTheme.backgroundLight.withOpacity(0.8),
            ],
          ),
        ),
        child: Obx(() {
          if (isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  style: AppTheme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un produit...',
                    hintStyle: TextStyle(color: AppTheme.textDark.withOpacity(0.5)),
                    filled: true,
                    fillColor: AppTheme.surfaceLight,
                    prefixIcon: Icon(Icons.search, color: AppTheme.primaryBrown),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: AppTheme.primaryBrown.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: AppTheme.accentGold, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) => _onCategorySelected(cat),
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
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: AppTheme.accentGold,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Produits populaires',
                          style: AppTheme.textTheme.displayMedium?.copyWith(
                            color: AppTheme.textDark,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => Get.to(() => const PromotionsPage()),
                      icon: Icon(
                        Icons.local_offer,
                        color: AppTheme.accentGold,
                        size: 24,
                      ),
                      label: Text(
                        'Promotions',
                        style: AppTheme.textTheme.bodyLarge?.copyWith(
                          color: AppTheme.primaryBrown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: AppTheme.primaryBrown.withOpacity(0.05),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () => Get.to(() => ProductDetailsPage(product: product)),
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
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                  child: Image.network(
                                    product.image,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 150,
                                        color: AppTheme.surfaceLight,
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: AppTheme.primaryBrown,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: AppTheme.textTheme.titleMedium?.copyWith(
                                          color: AppTheme.primaryBrown,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        product.price,
                                        style: AppTheme.textTheme.titleMedium?.copyWith(
                                          color: AppTheme.accentGold,
                                          fontWeight: FontWeight.w600,
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
                                children: [
                                  Material(
                                    color: AppTheme.primaryBrown.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(30),
                                    child: InkWell(
                                      onTap: () {
                                        final cartController = Get.find<CartController>();
                                        cartController.addToCart(
                                          CartItem(
                                            product: product,
                                            quantity: 1,
                                          ),
                                        );
                                        Get.snackbar(
                                          'Ajouté au panier',
                                          '${product.name} a été ajouté avec succès.',
                                          backgroundColor: AppTheme.surfaceLight.withOpacity(0.95),
                                          colorText: AppTheme.primaryBrown,
                                          snackPosition: SnackPosition.BOTTOM,
                                          margin: const EdgeInsets.all(16),
                                          borderRadius: 10,
                                          duration: const Duration(seconds: 3),
                                          boxShadows: AppTheme.defaultShadow,
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(30),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Icon(
                                          Icons.shopping_cart_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Material(
                                    color: AppTheme.primaryBrown.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(30),
                                    child: InkWell(
                                      onTap: () {
                                        if (favoritesController.isFavorite(product)) {
                                          favoritesController.removeFromFavorites(product);
                                        } else {
                                          favoritesController.addToFavorites(product);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(30),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Obx(() => Icon(
                                          favoritesController.isFavorite(product)
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: favoritesController.isFavorite(product)
                                              ? Colors.red
                                              : Colors.white,
                                          size: 20,
                                        )),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
