import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

class PswdOubliePage extends StatefulWidget {
  const PswdOubliePage({super.key});

  @override
  State<PswdOubliePage> createState() => _PswdOubliePageState();
}

class _PswdOubliePageState extends State<PswdOubliePage>
    with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez entrer votre adresse e-mail',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());
      Get.snackbar(
        'Succès',
        'Un e-mail de réinitialisation a été envoyé à votre adresse',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        duration: const Duration(seconds: 3),
      );
      Get.offNamed(AppRoutes.validCodePage);
    } on FirebaseAuthException catch (e) {
      String message = 'Une erreur est survenue';
      if (e.code == 'user-not-found') {
        message = 'Aucun utilisateur trouvé avec cette adresse e-mail';
      }
      Get.snackbar(
        'Erreur',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(Icons.arrow_back_ios, color: AppTheme.primaryBrown),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.surfaceLight,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ShaderMask(
                        shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                            child: Text(
                          'Mot de passe oublié',
                          style: AppTheme.textTheme.displayLarge,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Entrez votre e-mail pour réinitialiser votre mot de passe',
                        style: AppTheme.textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textDark.withOpacity(0.7),
                          ),
                      ),
                      const SizedBox(height: 40),
                      TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                        style: AppTheme.textTheme.bodyLarge,
                          decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryBrown),
                          labelStyle: TextStyle(color: AppTheme.primaryBrown),
                            filled: true,
                          fillColor: AppTheme.surfaceLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: AppTheme.primaryBrown.withOpacity(0.1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: AppTheme.primaryBrown.withOpacity(0.2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: AppTheme.accentGold, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _resetPassword,
                          style: AppTheme.primaryButtonStyle,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                                    'Réinitialiser',
                                    style: TextStyle(
                                      fontSize: 18,
                                      letterSpacing: 0.5,
                                        ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => Get.back(),
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: AppTheme.primaryBrown,
                          ),
                          label: Text(
                            "Retour à la connexion",
                            style: AppTheme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primaryBrown,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: AppTheme.surfaceLight,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
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
