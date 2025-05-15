import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';
import 'home_page.dart';

class PaymentPage extends StatelessWidget {
  final ProductModel product;
  final String paymentMethod;

  const PaymentPage({super.key, required this.product, required this.paymentMethod});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFF5E6D3),
                const Color(0xFFF0D9B5),
              ],
            ),
          ),
        ),
        iconTheme: IconThemeData(color: AppTheme.primaryBrown),
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              AppTheme.accentGold,
              AppTheme.primaryBrown.withOpacity(0.8),
              AppTheme.accentGold,
            ],
          ).createShader(bounds),
          child: Text(
            'Paiement',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontWeight: FontWeight.w600,
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
              const Color(0xFFFDF6E9),
              const Color(0xFFF5E6D3),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Hero(
                  tag: 'product_${product.name}',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBrown.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        product.image,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.image,
                          size: 100,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                product.name,
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBrown,
                  letterSpacing: 0.5,
                  height: 1.2,
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
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Playfair Display',
                    color: AppTheme.primaryBrown,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Playfair Display',
                        fontStyle: FontStyle.italic,
                        color: AppTheme.primaryBrown.withOpacity(0.9),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                product.description,
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Roboto',
                  color: AppTheme.primaryBrown.withOpacity(0.8),
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      const Color(0xFFFAF3E8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBrown.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryBrown.withOpacity(0.1),
                            AppTheme.primaryBrown.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.payment,
                        color: AppTheme.primaryBrown,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Mode de paiement : $paymentMethod',
                      style: TextStyle(
                        color: AppTheme.primaryBrown,
                        fontFamily: 'Playfair Display',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF3E8),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.1),
                      offset: const Offset(0, -4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.snackbar(
                            'Paiement',
                            'Paiement via $paymentMethod réussi ! Merci pour votre achat.',
                            backgroundColor: Colors.green.shade100,
                            colorText: AppTheme.primaryBrown,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ).copyWith(
                          backgroundColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.pressed)) {
                              return const Color(0xFFD4956A);
                            }
                            return const Color(0xFFC88850);
                          }),
                          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.2)),
                        ),
                        child: Text(
                          'Confirmer le paiement',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Get.offAll(() => const HomePage());
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryBrown,
                      ),
                      child: Text(
                        '← Retour à l\'accueil',
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 16,
                          color: AppTheme.primaryBrown.withOpacity(0.8),
                          letterSpacing: 0.3,
                        ),
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
