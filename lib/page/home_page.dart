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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> categories = ['Tout', 'Cosmétiques', 'Nourriture', 'Décoration', 'Accessoires'];
  String selectedCategory = 'Tout';

  final FavoritesController favoritesController = Get.find();
  final AuthController authController = Get.find();

  final List<ProductModel> promotions = [
    ProductModel(
      id: '1',
      name: "Savon naturel",
      price: "8,00 TND",
      image: "assets/savon.jpeg",
      description: "Savon à base d'huile d'olive 100% naturel.",
      artisan: "Artisan zouhra",
      category: "Cosmétiques",
    ),
    ProductModel(
      id: '2',
      name: "Huile d'olive bio",
      price: "18,00 TND",
      image: "assets/huile.jpeg",
      description: "Huile d'olive extra vierge, pressée à froid.",
      artisan: "Artisan Fatma",
      category: "Nourriture",
    ),
    ProductModel(
      id: '3',
      name: "Tapis berbère",
      price: "110,00 TND",
      image: "assets/tapis.jpeg",
      description: "Tapis traditionnel fait main.",
      artisan: "Artisan Khadija",
      category: "Décoration",
    ),
    ProductModel(
      id: '4',
      name: "Poterie artisanale",
      price: "45,00 TND",
      image: "assets/poterie.jpeg",
      description: "Poterie traditionnelle peinte à la main.",
      artisan: "Artisan Amira",
      category: "Décoration",
    ),
    ProductModel(
      id: '5',
      name: "Épices traditionnelles",
      price: "12,00 TND",
      image: "assets/epices.jpeg",
      description: "Mélange d'épices authentiques pour la cuisine traditionnelle.",
      artisan: "Artisan Yasmine",
      category: "Nourriture",
    ),
    ProductModel(
      id: '6',
      name: "Bijoux en argent",
      price: "85,00 TND",
      image: "assets/bijoux.jpeg",
      description: "Bijoux artisanaux en argent fait main.",
      artisan: "Artisan Samia",
      category: "Accessoires",
    ),
    ProductModel(
      id: '7',
      name: "Coussin traditionnel",
      price: "35,00 TND",
      image: "assets/coussin.jpeg",
      description: "Coussin décoratif avec broderies traditionnelles.",
      artisan: "Artisan Leila",
      category: "Décoration",
    ),
    ProductModel(
      id: '8',
      name: "Miel de thym",
      price: "25,00 TND",
      image: "assets/miel.jpeg",
      description: "Miel de thym pur et naturel des montagnes.",
      artisan: "Artisan Karima",
      category: "Nourriture",
    ),
    ProductModel(
      id: '9',
      name: "Céramique peinte",
      price: "55,00 TND",
      image: "assets/ceramique.jpeg",
      description: "Assiette en céramique peinte à la main.",
      artisan: "Artisan Nadia",
      category: "Décoration",
    ),
    ProductModel(
      id: '10',
      name: "Huile essentielle",
      price: "30,00 TND",
      image: "assets/huile_essentielle.jpeg",
      description: "Huile essentielle de romarin 100% pure.",
      artisan: "Artisan souad",
      category: "Cosmétiques",
    ),
  ];

  List<ProductModel> filteredPromotions = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    filteredPromotions = promotions;
  }

  void _applyFilters() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredPromotions = promotions.where((product) {
        final matchCategory = selectedCategory == 'Tout' || product.category == selectedCategory;
        final matchSearch = product.name.toLowerCase().contains(query) ||
            product.description.toLowerCase().contains(query);
        return matchCategory && matchSearch;
      }).toList();
    });
  }

  void _onCategorySelected(String category) {
    selectedCategory = category;
    _applyFilters();
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
        child: SingleChildScrollView(
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
              itemCount: filteredPromotions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final product = filteredPromotions[index];
                return GestureDetector(
                  onTap: () => Get.to(() => ProductDetailsPage(product: product)),
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppTheme.defaultShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Stack(
                            children: [
                              Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppTheme.primaryBrown.withOpacity(0.1),
                                      AppTheme.surfaceLight,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Image.asset(product.image, height: 90),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    final isFavori = favoritesController.favorites.any((p) => p.id == product.id);
                                    if (isFavori) {
                                      favoritesController.removeFromFavorites(product.id);
                                    } else {
                                      favoritesController.addToFavorites(product);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceLight,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Obx(() {
                                      final isFavori = favoritesController.favorites.any((p) => p.id == product.id);
                                      return Icon(
                                        isFavori ? Icons.favorite : Icons.favorite_border,
                                        color: isFavori ? Colors.red : AppTheme.primaryBrown,
                                        size: 20,
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                            product.name,
                                  style: AppTheme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                        ),
                                const SizedBox(height: 4),
                                Text(
                            product.price,
                                  style: TextStyle(
                                    color: AppTheme.accentGold,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
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
        ),
      ),
    );
  }
}
