import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/cart_item_model.dart';
import '../theme/app_theme.dart';
import '../controllers/cart_controller.dart';
import 'home_page.dart';

class CartPaymentPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double total;
  final String paymentMethod;

  const CartPaymentPage({
    super.key,
    required this.cartItems,
    required this.total,
    required this.paymentMethod,
  });

  @override
  State<CartPaymentPage> createState() => _CartPaymentPageState();
}

class _CartPaymentPageState extends State<CartPaymentPage> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvcController = TextEditingController();
  final CartController cartController = Get.find();

  bool isCardPayment = false;
  bool isDeliveryPayment = false;
  bool isApplePay = false;

  @override
  void initState() {
    super.initState();
    isCardPayment = widget.paymentMethod == 'Carte';
    isDeliveryPayment = widget.paymentMethod == 'Livraison';
    isApplePay = widget.paymentMethod == 'Apple Pay';
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    cardHolderController.dispose();
    expiryDateController.dispose();
    cvcController.dispose();
    super.dispose();
  }

  void _processPayment() {
    if (isCardPayment) {
      if (cardNumberController.text.isEmpty ||
          cardHolderController.text.isEmpty ||
          expiryDateController.text.isEmpty ||
          cvcController.text.isEmpty) {
        Get.snackbar(
          'Erreur',
          'Veuillez remplir tous les champs',
          backgroundColor: AppTheme.surfaceLight.withOpacity(0.95),
          colorText: AppTheme.primaryBrown,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 10,
          duration: const Duration(seconds: 3),
          boxShadows: AppTheme.defaultShadow,
        );
        return;
      }
    }

    // Simuler le traitement du paiement
    Get.snackbar(
      'Succès',
      isCardPayment
          ? 'Paiement par carte effectué avec succès !'
          : 'Commande confirmée, paiement à la livraison !',
      backgroundColor: AppTheme.surfaceLight.withOpacity(0.95),
      colorText: AppTheme.primaryBrown,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
      boxShadows: AppTheme.defaultShadow,
    );

    // Vider le panier
    cartController.clearCart();

    // Rediriger vers la page d'accueil
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAll(() =>  HomePage());
    });
  }

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
            isCardPayment ? 'Paiement par carte' : 'Paiement à la livraison',
            style: AppTheme.textTheme.displayMedium?.copyWith(
              fontSize: 22,
              letterSpacing: 0.5,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Résumé de la commande
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBrown.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Résumé de la commande',
                        style: AppTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...widget.cartItems.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.product.name} x${item.quantity}',
                                style: AppTheme.textTheme.bodyLarge,
                              ),
                            ),
                            Text(
                              '${(item.product.getPriceAsDouble() * item.quantity).toStringAsFixed(2)} TND',
                              style: AppTheme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: AppTheme.textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryBrown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.total.toStringAsFixed(2)} TND',
                            style: AppTheme.textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryBrown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                if (isCardPayment) ...[
                  // Formulaire de carte bancaire
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBrown.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations de paiement',
                          style: AppTheme.textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryBrown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: cardNumberController,
                          decoration: InputDecoration(
                            labelText: 'Numéro de carte',
                            prefixIcon: Icon(Icons.credit_card, color: AppTheme.primaryBrown),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: cardHolderController,
                          decoration: InputDecoration(
                            labelText: 'Nom du titulaire',
                            prefixIcon: Icon(Icons.person, color: AppTheme.primaryBrown),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: expiryDateController,
                                decoration: InputDecoration(
                                  labelText: 'Date d\'expiration',
                                  prefixIcon: Icon(Icons.calendar_today, color: AppTheme.primaryBrown),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: cvcController,
                                decoration: InputDecoration(
                                  labelText: 'CVC',
                                  prefixIcon: Icon(Icons.security, color: AppTheme.primaryBrown),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                if (isDeliveryPayment) ...[
                  // Informations de livraison
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBrown.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paiement à la livraison',
                          style: AppTheme.textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryBrown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Vous paierez le montant total de ${widget.total.toStringAsFixed(2)} TND à la livraison.',
                          style: AppTheme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Assurez-vous d\'avoir le montant exact lors de la livraison.',
                          style: AppTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryBrown.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                
                // Bouton de confirmation
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _processPayment,
                    style: AppTheme.primaryButtonStyle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        isCardPayment ? 'Confirmer et payer' : 'Confirmer la commande',
                        style: AppTheme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Transaction 100% sécurisée - SSL 256-bit',
                    style: AppTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryBrown.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 