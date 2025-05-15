import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_validateInputs()) return;

    setState(() => isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Get.offNamed(AppRoutes.mainNavigation);
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Une erreur est survenue';
      if (e.code == 'user-not-found') {
        errorMsg = 'Aucun compte trouvé avec cet email';
      } else if (e.code == 'wrong-password') {
        errorMsg = 'Mot de passe incorrect';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'Format d\'email invalide';
      }
      _showError(errorMsg);
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool _validateInputs() {
    if (emailController.text.trim().isEmpty) {
      _showError('Veuillez entrer votre email');
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      _showError('Veuillez entrer votre mot de passe');
      return false;
    }
    return true;
  }

  void _showError(String message) {
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
                        'Connexion',
                        style: AppTheme.textTheme.displayLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bienvenue ! Connectez-vous pour découvrir notre artisanat',
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
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      style: AppTheme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryBrown),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: AppTheme.primaryBrown,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        labelStyle: TextStyle(color: AppTheme.primaryBrown),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.pswdOubliePage),
                        child: Text(
                          'Mot de passe oublié ?',
                          style: AppTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryBrown,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _signIn,
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
                                  'Se connecter',
                                  style: TextStyle(
                                    fontSize: 18,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Get.toNamed(AppRoutes.signup),
                        style: AppTheme.secondaryButtonStyle,
                        child: const Text(
                          'Créer un compte',
                          style: TextStyle(fontSize: 18, letterSpacing: 0.5),
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
    );
  }
}
