import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'category_products_page.dart';
import '../theme/app_theme.dart';

class ProductCategoriesPage extends StatelessWidget {
  const ProductCategoriesPage({super.key});

  final List<Map<String, dynamic>> categories = const [
    {
      'title': 'Cosmétiques',
      'image': 'assets/categories/cosmetiques.png',
      'category': 'cosmetiques',
    },
    {
      'title': 'Nourriture',
      'image': 'assets/categories/nourriture.png',
      'category': 'nourriture',
    },
    {
      'title': 'Décoration',
      'image': 'assets/categories/decoration.png',
      'category': 'decoration',
    },
    {
      'title': 'Textile',
      'image': 'assets/categories/textile.png',
      'category': 'textile',
    },
  ];

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
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
          child: Text(
            'Catégories',
            style: AppTheme.textTheme.displayMedium?.copyWith(
              fontSize: 24,
              letterSpacing: 0.5,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: AppTheme.primaryBrown),
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
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () => Get.to(() => CategoryProductsPage(category: category['category'])),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBrown.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(category['image'], height: 80),
                    const SizedBox(height: 10),
                    Text(
                      category['title'],
                      style: AppTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryBrown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
