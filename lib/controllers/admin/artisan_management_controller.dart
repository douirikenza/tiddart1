import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminArtisanController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Map<String, dynamic>> artisans = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchArtisans();
  }

  Future<void> fetchArtisans() async {
    try {
      isLoading.value = true;
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'artisan')
          .get();
      
      artisans.value = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>
        };
      }).toList();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les artisans');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveArtisan(String artisanId) async {
    try {
      isLoading.value = true;
      await _firestore.collection('users').doc(artisanId).update({
        'isApproved': true,
        'approvedAt': FieldValue.serverTimestamp(),
      });
      await fetchArtisans();
      Get.snackbar('Succès', 'Artisan approuvé avec succès');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'approuver l\'artisan');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectArtisan(String artisanId) async {
    try {
      isLoading.value = true;
      await _firestore.collection('users').doc(artisanId).delete();
      await fetchArtisans();
      Get.snackbar('Succès', 'La demande de l\'artisan a été rejetée et supprimée.');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de rejeter l\'artisan');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> suspendArtisan(String artisanId) async {
    try {
      isLoading.value = true;
      await _firestore.collection('users').doc(artisanId).update({
        'isSuspended': true,
        'suspendedAt': FieldValue.serverTimestamp(),
      });
      await fetchArtisans();
      Get.snackbar('Succès', 'Artisan suspendu avec succès');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de suspendre l\'artisan');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> unsuspendArtisan(String artisanId) async {
    try {
      isLoading.value = true;
      await _firestore.collection('users').doc(artisanId).update({
        'isSuspended': false,
        'unsuspendedAt': FieldValue.serverTimestamp(),
      });
      await fetchArtisans();
      Get.snackbar('Succès', 'Artisan réactivé avec succès');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de réactiver l\'artisan');
    } finally {
      isLoading.value = false;
    }
  }
} 