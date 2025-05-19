import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';
import '../routes/app_routes.dart';

class CategoryProductsPage extends StatelessWidget {
  final String category;
  final ProductController productController = Get.put(ProductController());

  CategoryProductsPage({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: FutureBuilder<void>(
        future: productController.fetchProducts(categoryId: category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Obx(() {
            if (productController.products.isEmpty) {
              return const Center(
                child: Text(
                  'Aucun produit trouvé dans cette catégorie',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return GridView.builder(
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
                return GestureDetector(
                  onTap: () => Get.toNamed(
                    AppRoutes.productDetails,
                    arguments: product,
                  ),
                  child: Card(
                    elevation: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
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
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${product.price.toStringAsFixed(2)} €',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!product.isAvailable)
                                const Text(
                                  'Non disponible',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
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
          });
        },
      ),
    );
  }
} 