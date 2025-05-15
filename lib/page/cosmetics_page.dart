import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';
import 'product_details_page.dart';

class CosmeticsPage extends StatelessWidget {
  CosmeticsPage({super.key});

  final List<ProductModel> cosmetics = [
    ProductModel(
      id: 'c1',
      name: 'Savon naturel',
      price: '8,00 TND',
      image: 'assets/products/savon.png',
      description: "Savon bio à base d'huile d'olive",
      artisan: 'Artisan Amal',
      category: 'Cosmétiques',
    ),
    ProductModel(
      id: 'c2',
      name: 'Crème hydratante',
      price: '22,00 TND',
      image: 'assets/products/creme.png',
      description: 'Crème à l’huile d’argan naturelle',
      artisan: 'Artisan Sarah',
      category: 'Cosmétiques',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _buildCategoryPage('Cosmétiques', cosmetics);
  }

  Widget _buildCategoryPage(String title, List<ProductModel> products) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0D9B5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0D9B5),
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        iconTheme: const IconThemeData(color: Colors.brown),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
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
                color: const Color(0xFFE2BF91),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border, color: Color(0xFF4B2706)),
                      onPressed: () {},
                    ),
                  ),
                  Center(
                    child: Image.asset(product.image, height: 90),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      product.price,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.brown,
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
  }
}
