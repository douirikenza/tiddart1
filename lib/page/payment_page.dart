import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';
import 'home_page.dart';
import 'delivery_form_page.dart';

class PaymentPage extends StatelessWidget {
  final ProductModel product;
  final String paymentMethod;

  const PaymentPage({super.key, required this.product, required this.paymentMethod});

  void _handlePaymentConfirmation() {
    if (paymentMethod == 'Livraison') {
      Get.to(() => DeliveryFormPage(product: product));
    } else {
      Get.snackbar(
        'Succès',
        'Paiement effectué avec succès',
        backgroundColor: AppTheme.surfaceLight.withOpacity(0.95),
        colorText: AppTheme.primaryBrown,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        duration: const Duration(seconds: 3),
        boxShadows: AppTheme.defaultShadow,
      );
      Get.offAll(() => const HomePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryBrown),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Confirmation',
          style: AppTheme.textTheme.displayMedium?.copyWith(
            color: AppTheme.primaryBrown,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.defaultShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Détails de la commande',
                    style: AppTheme.textTheme.displayMedium?.copyWith(
                      color: AppTheme.textDark,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildOrderDetails(),
                  const SizedBox(height: 24),
                  _buildPaymentMethodCard(),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.defaultShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Récapitulatif',
                    style: AppTheme.textTheme.displayMedium?.copyWith(
                      color: AppTheme.textDark,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildPriceSummary(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _handlePaymentConfirmation,
          style: AppTheme.primaryButtonStyle.copyWith(
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 16),
            ),
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return AppTheme.primaryBrown.withOpacity(0.9);
              }
              return AppTheme.primaryBrown;
            }),
          ),
          child: Text(
            paymentMethod == 'Livraison' ? 'Continuer vers la livraison' : 'Confirmer le paiement',
            style: AppTheme.textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(product.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(
            product.name,
            style: AppTheme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Par ${product.artisan}',
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textDark.withOpacity(0.7),
            ),
          ),
          trailing: Text(
            '${product.price}',
            style: AppTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.accentGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getPaymentMethodColor(paymentMethod).withOpacity(0.1),
            _getPaymentMethodColor(paymentMethod).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _getPaymentMethodColor(paymentMethod).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getPaymentMethodColor(paymentMethod).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getPaymentMethodIcon(paymentMethod),
              color: _getPaymentMethodColor(paymentMethod),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getPaymentMethodLabel(paymentMethod),
                  style: AppTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getPaymentMethodColor(paymentMethod),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mode de paiement sélectionné',
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textDark.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sous-total',
              style: AppTheme.textTheme.bodyMedium,
            ),
            Text(
              '${product.price}',
              style: AppTheme.textTheme.bodyLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Frais de livraison',
              style: AppTheme.textTheme.bodyMedium,
            ),
            Text(
              paymentMethod == 'Livraison' ? 'À calculer' : 'Gratuit',
              style: AppTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.accentGold,
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: AppTheme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${product.price}',
              style: AppTheme.textTheme.displayMedium?.copyWith(
                color: AppTheme.primaryBrown,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'PayPal':
        return Icons.paypal;
      case 'Carte':
        return Icons.credit_card;
      case 'Livraison':
        return Icons.local_shipping;
      default:
        return Icons.payment;
    }
  }

  Color _getPaymentMethodColor(String method) {
    switch (method) {
      case 'PayPal':
        return const Color(0xFF0070BA);
      case 'Carte':
        return const Color(0xFF1A1F71);
      case 'Livraison':
        return const Color(0xFF2E7D32);
      default:
        return AppTheme.primaryBrown;
    }
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'PayPal':
        return 'PayPal';
      case 'Carte':
        return 'Carte Bancaire';
      case 'Livraison':
        return 'Paiement à la Livraison';
      default:
        return method;
    }
  }
}
