import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../routes/app_routes.dart';
import './profile_controller.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  void _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAllNamed(AppRoutes.welcome);
    } else {
      // Charger les données du profil après la connexion
      final ProfileController profileController = Get.find<ProfileController>();
      profileController.loadUserData();
      Get.offAllNamed(AppRoutes.mainNavigation);
    }
  }

  // Obtenir les informations de l'utilisateur actuel depuis Firestore
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      if (firebaseUser.value != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(firebaseUser.value!.uid)
            .get();
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print("Erreur lors de la récupération des données utilisateur: $e");
      return null;
    }
  }

  // Vérifier si l'utilisateur est un artisan
  Future<bool> isArtisan() async {
    try {
      var userData = await getCurrentUserData();
      return userData?['role'] == 'artisan';
    } catch (e) {
      print("Erreur lors de la vérification du rôle: $e");
      return false;
    }
  }

  // Connexion avec email et mot de passe
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      // Charger les données du profil après la connexion réussie
      final ProfileController profileController = Get.find<ProfileController>();
      await profileController.loadUserData();
      
    } catch (e) {
      Get.snackbar(
        "Erreur de connexion",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.brown,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Inscription avec email et mot de passe
  Future<void> signup(String name, String email, String password, bool isArtisan) async {
    try {
      isLoading.value = true;
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Créer le profil utilisateur dans Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'role': isArtisan ? 'artisan' : 'client',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Mettre à jour le nom d'affichage
      await result.user!.updateDisplayName(name);
      
      // Charger les données du profil après l'inscription réussie
      final ProfileController profileController = Get.find<ProfileController>();
      await profileController.loadUserData();

    } catch (e) {
      Get.snackbar(
        "Erreur d'inscription",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.brown,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      await _auth.signOut();
      // Réinitialiser les données du profil
      final ProfileController profileController = Get.find<ProfileController>();
      profileController.userData.value = null;
    } catch (e) {
      Get.snackbar(
        "Erreur de déconnexion",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.brown,
      );
    }
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      Get.snackbar(
        "Réinitialisation du mot de passe",
        "Un email a été envoyé à $email",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.brown,
      );
    } catch (e) {
      Get.snackbar(
        "Erreur",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.brown,
      );
    }
  }
} 