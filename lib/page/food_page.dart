import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';
import 'product_details_page.dart';

class FoodPage extends StatelessWidget {
  FoodPage({super.key});

  final List<ProductModel> foodItems = [
    ProductModel(
      id: 'f1',
      name: 'Huile d’olive bio',
      price: '18,00 TND',
      image: 'assets/products/huile.png',
      description: 'Huile extra vierge 100% locale',
      artisan: 'Artisan Fatma',
      category: 'Nourriture',
    ),
    ProductModel(
      id: 'f2',
      name: 'Miel naturel',
      price: '25,00 TND',
      image: 'assets/products/miel.png',
      description: 'Miel pur de montagne',
      artisan: 'Artisan Saber',
      category: 'Nourriture',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _buildCategoryPage('Nourriture', foodItems);
  }

  Widget _buildCategoryPage(String title, List<ProductModel> products) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0D9B5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0D9B5),
        elevation: 0,
        title: Text(title, style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.brown),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () => Get.to(() => ProductDetailsPage(product: product)),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE2BF91),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(product.image, height: 80),
                  const SizedBox(height: 10),
                  Text(product.name, style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
                  Text(product.price, style: const TextStyle(color: Colors.brown)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
