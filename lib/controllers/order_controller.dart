import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxBool isLoading = false.obs;
  final RxList orders = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final QuerySnapshot ordersSnapshot = await _firestore
          .collection('orders')
          .where('artisanId', isEqualTo: 'current_artisan_id') // À remplacer par l'ID réel de l'artisan
          .get();

      orders.value = ordersSnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Erreur lors de la récupération des commandes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Statistiques
  int get totalOrders => orders.length;
  
  double get totalRevenue {
    return orders.fold(0.0, (sum, order) => sum + (order['total'] ?? 0.0));
  }
  
  int get uniqueCustomers {
    final customerIds = orders.map((order) => order['customerId']).toSet();
    return customerIds.length;
  }
  
  int get pendingOrders {
    return orders.where((order) => order['status'] == 'pending').length;
  }
  
  int get deliveredOrders {
    return orders.where((order) => order['status'] == 'delivered').length;
  }
  
  int get cancelledOrders {
    return orders.where((order) => order['status'] == 'cancelled').length;
  }
  
  double get satisfactionRate {
    final ratedOrders = orders.where((order) => order['rating'] != null);
    if (ratedOrders.isEmpty) return 0;
    final totalRating = ratedOrders.fold(0.0, (sum, order) => sum + (order['rating'] ?? 0.0));
    return totalRating / ratedOrders.length;
  }

  // Données pour le graphique des ventes
  List<Map<String, dynamic>> getSalesData(String period) {
    // TODO: Implémenter la logique pour obtenir les données de vente selon la période
    return [];
  }

  // Statistiques par catégorie
  Map<String, double> getCategoryStats() {
    final Map<String, double> stats = {};
    final totalProducts = orders.fold<int>(0, (sum, order) => sum + ((order['products']?.length ?? 0) as int));
    
    for (var order in orders) {
      final products = order['products'] ?? [];
      for (var product in products) {
        final category = product['category'];
        if (category != null) {
          stats[category] = (stats[category] ?? 0) + 1;
        }
      }
    }

    // Convertir en pourcentages
    if (totalProducts > 0) {
      stats.forEach((key, value) {
        stats[key] = (value / totalProducts) * 100;
      });
    }

    return stats;
  }
} 