import 'dart:io';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  var profileImage = Rx<File?>(null);
  var userData = Rx<Map<String, dynamic>?>(null);
  var userOrders = RxList<Map<String, dynamic>>([]);
  var isLoading = true.obs;
  var error = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    // Écouter les changements d'état d'authentification
    ever(_auth.currentUser.obs, (User? user) {
      if (user != null) {
        loadUserData();
        loadUserOrders();
      } else {
        userData.value = null;
        userOrders.clear();
      }
    });
    
    // Charger les données si l'utilisateur est déjà connecté
    if (_auth.currentUser != null) {
      loadUserData();
      loadUserOrders();
    }
  }

  Future<void> loadUserData() async {
    try {
      error.value = null;
      isLoading.value = true;
      User? currentUser = _auth.currentUser;
      
      if (currentUser != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
            
        if (doc.exists) {
          userData.value = doc.data() as Map<String, dynamic>;
        } else {
          // Si le document n'existe pas, créer un document par défaut
          await _firestore.collection('users').doc(currentUser.uid).set({
            'name': currentUser.displayName ?? 'Utilisateur',
            'email': currentUser.email,
            'role': 'client', // Rôle par défaut
            'phone': '',
            'address': '',
            'createdAt': FieldValue.serverTimestamp(),
          });
          
          // Recharger les données
          doc = await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .get();
          userData.value = doc.data() as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print("Erreur lors du chargement des données utilisateur: $e");
      error.value = "Impossible de charger les données utilisateur";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserOrders() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final ordersSnapshot = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: currentUser.uid)
            .orderBy('createdAt', descending: true)
            .get();

        userOrders.value = ordersSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      }
    } catch (e) {
      print("Erreur lors du chargement des commandes: $e");
    }
  }

  void setProfileImage(File image) {
    profileImage.value = image;
  }

  Future<void> updateUserData({
    String? name,
    String? email,
    String? phone,
    String? address,
  }) async {
    try {
      error.value = null;
      isLoading.value = true;
      User? currentUser = _auth.currentUser;
      
      if (currentUser != null) {
        Map<String, dynamic> updateData = {};
        
        if (name != null) {
          updateData['name'] = name;
          await currentUser.updateDisplayName(name);
        }
        
        if (email != null && email != currentUser.email) {
          updateData['email'] = email;
          await currentUser.updateEmail(email);
        }

        if (phone != null) updateData['phone'] = phone;
        if (address != null) updateData['address'] = address;
        
        if (updateData.isNotEmpty) {
          await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .update(updateData);
        }
        
        await loadUserData(); // Recharger les données
      }
    } catch (e) {
      print("Erreur lors de la mise à jour des données: $e");
      error.value = "Impossible de mettre à jour les informations";
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
