import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isArtisan = false;

  // Controllers pour les animations
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _buttonController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _buttonOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialisation des controllers
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Configuration des animations
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOutCubic,
    ));
    _buttonScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.elasticOut,
    ));
    _buttonOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));

    // Démarrage des animations
    Future.delayed(const Duration(milliseconds: 200), () {
    _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
    _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
    _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _rotationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar("Erreur", "Les mots de passe ne correspondent pas",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.surfaceLight.withOpacity(0.95),
          colorText: AppTheme.primaryBrown,
          margin: const EdgeInsets.all(16),
          borderRadius: 10,
          duration: const Duration(seconds: 3),
          boxShadows: AppTheme.defaultShadow);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Mettre à jour le profil de l'utilisateur avec son rôle
      await userCredential.user?.updateDisplayName(nameController.text.trim());
      
      // Stocker le rôle de l'utilisateur dans Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': _isArtisan ? 'artisan' : 'client',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.offAllNamed(AppRoutes.login);
    } on FirebaseAuthException catch (e) {
      String message = 'Erreur lors de la création du compte';
      if (e.code == 'email-already-in-use') {
        message = 'E-mail déjà utilisé';
      } else if (e.code == 'weak-password') {
        message = 'Mot de passe trop faible';
      }
      Get.snackbar("Erreur", message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.surfaceLight.withOpacity(0.95),
          colorText: AppTheme.primaryBrown,
          margin: const EdgeInsets.all(16),
          borderRadius: 10,
          duration: const Duration(seconds: 3),
          boxShadows: AppTheme.defaultShadow);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Get.offAllNamed(AppRoutes.mainNavigation);
    } catch (e) {
      Get.snackbar("Erreur Google", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.surfaceLight.withOpacity(0.95),
          colorText: AppTheme.primaryBrown,
          margin: const EdgeInsets.all(16),
          borderRadius: 10,
          duration: const Duration(seconds: 3),
          boxShadows: AppTheme.defaultShadow);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isConfirmPassword = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : (isConfirmPassword ? _obscureConfirmPassword : false),
        keyboardType: keyboardType,
        style: AppTheme.textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primaryBrown),
          suffixIcon: isPassword || isConfirmPassword
              ? IconButton(
                  icon: Icon(
                    (isPassword ? _obscurePassword : _obscureConfirmPassword)
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.primaryBrown,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isPassword) {
                        _obscurePassword = !_obscurePassword;
                      } else {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      }
                    });
                  },
                )
              : null,
          labelStyle: TextStyle(color: AppTheme.primaryBrown),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppTheme.surfaceLight,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Container(
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
        child: SafeArea(
          child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(Icons.arrow_back_ios, color: AppTheme.primaryBrown),
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.surfaceLight,
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ShaderMask(
                        shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                        child: Text(
                        'Créer un compte',
                          style: AppTheme.textTheme.displayLarge,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rejoignez-nous pour découvrir notre artisanat',
                        style: AppTheme.textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textDark.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildTextField(
                        controller: nameController,
                        label: 'Nom',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: passwordController,
                        label: 'Mot de passe',
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: confirmPasswordController,
                        label: 'Confirmer le mot de passe',
                        icon: Icons.lock_outline,
                        isConfirmPassword: true,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBrown.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CheckboxListTile(
                          title: Text(
                            'Je suis un artisan',
                            style: AppTheme.textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textDark,
                            ),
                          ),
                          value: _isArtisan,
                          onChanged: (bool? value) {
                            setState(() {
                              _isArtisan = value ?? false;
                            });
                          },
                          activeColor: AppTheme.primaryBrown,
                          checkColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ScaleTransition(
                        scale: _buttonScaleAnimation,
                        child: FadeTransition(
                          opacity: _buttonOpacityAnimation,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: AppTheme.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBrown.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                        onPressed: isLoading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                          ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                            : const Text(
                                'Créer un compte',
                                      style: TextStyle(
                                        fontSize: 18,
                                        letterSpacing: 0.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeTransition(
                        opacity: _buttonOpacityAnimation,
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(color: AppTheme.primaryBrown.withOpacity(0.3)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Ou',
                                style: AppTheme.textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.primaryBrown.withOpacity(0.7),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: AppTheme.primaryBrown.withOpacity(0.3)),
                            ),
                          ],
                              ),
                      ),
                      const SizedBox(height: 24),
                      ScaleTransition(
                        scale: _buttonScaleAnimation,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: AppTheme.defaultShadow,
                            ),
                            child: IconButton(
                              icon: Image.asset("assets/google.png", width: 24),
                        onPressed: _signInWithGoogle,
                              style: IconButton.styleFrom(
                                padding: const EdgeInsets.all(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeTransition(
                        opacity: _buttonOpacityAnimation,
                        child: Center(
                          child: TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.login),
                            child: Text(
                          'Vous avez déjà un compte ? Se connecter',
                              style: AppTheme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.primaryBrown,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
