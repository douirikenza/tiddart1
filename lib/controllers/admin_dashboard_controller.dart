import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardController extends GetxController {
  var totalArtisans = 0.obs;
  var totalCategories = 0.obs;
  var totalCommandes = 0.obs;

  @override
  void onInit() {
    super.onInit();

    // Listener temps réel pour artisans
    FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'artisan')
      .snapshots()
      .listen((snapshot) {
        totalArtisans.value = snapshot.size;
      });

    // Listener temps réel pour catégories
    FirebaseFirestore.instance.collection('categories').snapshots().listen((snapshot) {
      totalCategories.value = snapshot.size;
    });

    // Listener temps réel pour commandes
    FirebaseFirestore.instance.collection('commandes').snapshots().listen((snapshot) {
      totalCommandes.value = snapshot.size;
    });
  }
} 