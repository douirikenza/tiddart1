import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';
import 'payment_page.dart';

class PaymentChoicePage extends StatelessWidget {
  final ProductModel product;

  const PaymentChoicePage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> paymentMethods = [
      {
        'label': 'PayPal',
        'icon': Icons.account_balance_wallet,
        'method': 'PayPal',
      },
      {
        'label': 'Carte Bancaire',
        'icon': Icons.credit_card,
        'method': 'Carte',
      },
      {
        'label': 'Paiement à la Livraison',
        'icon': Icons.local_shipping,
        'method': 'Livraison',
      },
    ];

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
            'Choisir le mode de paiement',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontWeight: FontWeight.w600,
              fontSize: 22,
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
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: paymentMethods.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final method = paymentMethods[index];
            return Hero(
              tag: 'payment_${method['method']}',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Get.to(
                      () => PaymentPage(
                        product: product,
                        paymentMethod: method['method'],
                      ),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 400),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          const Color(0xFFFAF3E8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
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
                          padding: const EdgeInsets.all(12),
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
                            method['icon'],
                            color: AppTheme.primaryBrown,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          method['label'],
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Playfair Display',
                            color: AppTheme.primaryBrown,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBrown.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppTheme.primaryBrown.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
