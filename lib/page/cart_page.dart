import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../models/cart_item_model.dart';
import '../theme/app_theme.dart';
import 'cart_payment_choice_page.dart';

class CartPage extends StatelessWidget {
  CartPage({super.key});

  final CartController cartController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              AppTheme.accentGold,
              AppTheme.primaryBrown.withOpacity(0.8),
              AppTheme.accentGold,
            ],
          ).createShader(bounds),
          child: Text(
          'Mon Panier',
          style: TextStyle(
              fontFamily: 'Playfair Display',
              fontWeight: FontWeight.w600,
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
              const Color(0xFFFDF6E9),
              const Color(0xFFF5E6D3),
            ],
          ),
        ),
        child: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cartController.cartItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = cartController.cartItems[index];
                return _buildCartItem(item, index);
              },
            )),
          ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFAF3E8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.1),
                    offset: const Offset(0, -2),
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Playfair Display',
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBrown,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Obx(() => Text(
                        '${cartController.total.toStringAsFixed(2)} TND',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Playfair Display',
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBrown,
                          letterSpacing: 0.5,
            ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        if (cartController.cartItems.isNotEmpty) {
                          Get.to(() => CartPaymentChoicePage(
                            cartItems: cartController.cartItems,
                            total: cartController.total,
                          ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.pressed)) {
                            return AppTheme.primaryBrown.withOpacity(0.9);
                          }
                          return AppTheme.primaryBrown;
                        }),
                        overlayColor: MaterialStateProperty.all(AppTheme.accentGold.withOpacity(0.1)),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(27),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryBrown,
                              AppTheme.primaryBrown.withOpacity(0.9),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBrown.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_cart_checkout,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Acheter maintenant',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Playfair Display',
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFAF3E8),
            const Color(0xFFF3E2C7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'product_${item.product.name}',
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: Image.asset(
                item.product.image,
                height: 110,
                width: 110,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Playfair Display',
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBrown,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryBrown.withOpacity(0.1),
                              AppTheme.primaryBrown.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => cartController.changeQuantity(index, -1),
                              icon: const Icon(Icons.remove),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: AppTheme.primaryBrown,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryBrown.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                item.quantity.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryBrown,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => cartController.changeQuantity(index, 1),
                              icon: const Icon(Icons.add),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: AppTheme.primaryBrown,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => cartController.removeFromCart(cartController.cartItems[index]),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.primaryBrown.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                        ),
                        icon: Icon(
                          Icons.delete_outline,
                          color: AppTheme.primaryBrown,
                          size: 20,
                        ),
                      ),
                      Text(
                        item.getFormattedTotal(),
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBrown,
                          fontSize: 16,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
