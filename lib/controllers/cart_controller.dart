import 'package:get/get.dart';
import '../models/cart_item_model.dart';

class CartController extends GetxController {
  // Liste observable des articles du panier
  var cartItems = <CartItem>[].obs;

  // Ajouter un produit au panier
  void addToCart(CartItem item) {
    final index = cartItems.indexWhere((e) => e.name == item.name);
    if (index != -1) {
      cartItems[index].quantity += item.quantity;
    } else {
      cartItems.add(item);
    }
  }

  // Supprimer un produit du panier
  void removeFromCart(CartItem item) {
    cartItems.removeWhere((e) => e.name == item.name);
  }

  // Changer la quantité d’un produit
  void changeQuantity(int index, int delta) {
    final current = cartItems[index];
    current.quantity += delta;
    if (current.quantity <= 0) {
      cartItems.removeAt(index);
    } else {
      cartItems[index] = current; // forcer mise à jour GetX
    }
  }

  // Calculer le total du panier
  double get total => cartItems.fold(0, (sum, item) => sum + item.total);
}
