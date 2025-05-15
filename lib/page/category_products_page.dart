import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

class CategoryProductsPage extends StatelessWidget {
  final String category;
  final ProductController productController = Get.find<ProductController>();

  CategoryProductsPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.backgroundLight,
                AppTheme.surfaceLight,
              ],
            ),
          ),
        ),
        iconTheme: IconThemeData(color: AppTheme.primaryBrown),
        title: ShaderMask(
          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
          child: Text(
            category,
            style: AppTheme.textTheme.displayMedium?.copyWith(
              fontSize: 24,
              letterSpacing: 0.5,
            ),
          ),
        ),
        centerTitle: true,
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
        child: FutureBuilder<List<ProductModel>>(
          future: productController.getProductsByCategory(category),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erreur lors du chargement des produits',
                  style: AppTheme.textTheme.bodyLarge?.copyWith(
                    color: Colors.red,
                  ),
                ),
              );
            }

            final products = snapshot.data ?? [];

            if (products.isEmpty) {
              return Center(
                child: Text(
                  'Aucun produit trouvé dans cette catégorie',
                  style: AppTheme.textTheme.bodyLarge,
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return GestureDetector(
                  onTap: () => Get.toNamed(
                    AppRoutes.productDetails,
                    arguments: product,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBrown.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Hero(
                            tag: 'product_${product.name}',
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(product.image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
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
                              const SizedBox(height: 4),
                              Text(
                                product.price,
                                style: AppTheme.textTheme.titleSmall?.copyWith(
                                  color: AppTheme.accentGold,
                                  fontWeight: FontWeight.w600,
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
            );
          },
        ),
      ),
    );
  }
} 