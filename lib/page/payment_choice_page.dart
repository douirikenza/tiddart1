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
        'icon': Icons.paypal,
        'method': 'PayPal',
        'description': 'Paiement sécurisé et rapide',
        'color': const Color(0xFF0070BA),
      },
      {
        'label': 'Carte Bancaire',
        'icon': Icons.credit_card,
        'method': 'Carte',
        'description': 'Visa, Mastercard, etc.',
        'color': const Color(0xFF1A1F71),
      },
      {
        'label': 'Paiement à la Livraison',
        'icon': Icons.local_shipping,
        'method': 'Livraison',
        'description': 'Payez lors de la réception',
        'color': const Color(0xFF2E7D32),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryBrown),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Mode de paiement',
          style: TextStyle(
            color: AppTheme.primaryBrown,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Choisissez votre méthode de paiement préférée',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                final method = paymentMethods[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Get.to(
                        () => PaymentPage(
                          product: product,
                          paymentMethod: method['method'],
                        ),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  method['color'].withOpacity(0.05),
                                ],
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Get.to(
                                    () => PaymentPage(
                                      product: product,
                                      paymentMethod: method['method'],
                                    ),
                                    transition: Transition.rightToLeft,
                                    duration: const Duration(milliseconds: 300),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: method['color'].withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          method['icon'],
                                          color: method['color'],
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              method['label'],
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              method['description'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.grey[400],
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBrown,
                    AppTheme.primaryBrown.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBrown.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    // Action par défaut - premier mode de paiement
                    Get.to(
                      () => PaymentPage(
                        product: product,
                        paymentMethod: paymentMethods[0]['method'],
                      ),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                  child: const Center(
                    child: Text(
                      'Continuer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
