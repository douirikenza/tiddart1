import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';
import 'payment_choice_page.dart';

class ProductDetailsPage extends StatelessWidget {
  final ProductModel product;
  final CartController cartController = Get.find();

  ProductDetailsPage({super.key, required this.product});

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
            'Détails du produit',
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'product_${product.name}',
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBrown.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 50,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                      child: Text(
                        product.name,
                        style: AppTheme.textTheme.displayMedium?.copyWith(
                          fontSize: 28,
                          letterSpacing: 0.5,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentGold.withOpacity(0.15),
                            AppTheme.primaryBrown.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.price,
                        style: AppTheme.textTheme.displayMedium?.copyWith(
                          fontSize: 22,
                          color: AppTheme.primaryBrown,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      product.description,
                      style: AppTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textDark.withOpacity(0.8),
                        height: 1.6,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryBrown.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: AppTheme.primaryBrown.withOpacity(0.7),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Artisan : ${product.artisan}',
                            style: AppTheme.textTheme.bodyLarge?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppTheme.primaryBrown.withOpacity(0.9),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBrown.withOpacity(0.1),
                      offset: const Offset(0, -4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          cartController.addToCart(
                            CartItem(
                              name: product.name,
                              price: double.tryParse(
                                    product.price.replaceAll(RegExp(r'[^0-9.]'), ''),
                                  ) ??
                                  0.0,
                              image: product.image,
                              quantity: 1,
                            ),
                          );
                          Get.snackbar(
                            'Ajouté au panier',
                            '${product.name} a été ajouté avec succès.',
                            backgroundColor: Colors.green.shade100,
                            colorText: AppTheme.primaryBrown,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart, size: 22),
                        label: Text(
                          'Ajouter au panier',
                          style: AppTheme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                        style: AppTheme.primaryButtonStyle,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.to(() => PaymentChoicePage(product: product));
                        },
                        icon: const Icon(Icons.payment, size: 22),
                        label: Text(
                          'Acheter maintenant',
                          style: AppTheme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                        style: AppTheme.primaryButtonStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
