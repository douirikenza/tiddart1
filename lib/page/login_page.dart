import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
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
  final AuthController _authController = Get.find<AuthController>();
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

    try {
      await _authController.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    } catch (e) {
      _showError('Une erreur est survenue lors de la connexion');
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
      backgroundColor: AppTheme.surfaceLight.withOpacity(0.95),
      colorText: AppTheme.primaryBrown,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
      boxShadows: AppTheme.defaultShadow,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.backgroundLight,
                    AppTheme.surfaceLight,
                  ],
                ),
              ),
              child: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 40),
                          // Logo ou Image
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.surfaceLight,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBrown.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              size: 60,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Titre
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppTheme.primaryGradient.createShader(bounds),
                            child: Text(
                              'Bienvenue',
                              style: AppTheme.textTheme.displayLarge?.copyWith(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Connectez-vous pour découvrir notre artisanat',
                            style: AppTheme.textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textDark.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                          // Champs de formulaire
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBrown.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                TextField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: TextStyle(color: AppTheme.primaryBrown),
                                    prefixIcon: Icon(Icons.email, color: AppTheme.primaryBrown),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppTheme.primaryBrown.withOpacity(0.3)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppTheme.primaryBrown.withOpacity(0.3)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppTheme.primaryBrown, width: 2),
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'Mot de passe',
                                    labelStyle: TextStyle(color: AppTheme.primaryBrown),
                                    prefixIcon: Icon(Icons.lock, color: AppTheme.primaryBrown),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: AppTheme.primaryBrown,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppTheme.primaryBrown.withOpacity(0.3)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppTheme.primaryBrown.withOpacity(0.3)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppTheme.primaryBrown, width: 2),
                                    ),
                                  ),
                                  obscureText: _obscurePassword,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Bouton de connexion
                          ElevatedButton(
                            onPressed: _authController.isLoading.value ? null : _signIn,
                            style: AppTheme.primaryButtonStyle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: _authController.isLoading.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Se connecter',
                                      style: AppTheme.textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Liens supplémentaires
                          TextButton(
                            onPressed: () => Get.toNamed(AppRoutes.pswdOubliePage),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryBrown,
                            ),
                            child: Text(
                              'Mot de passe oublié ?',
                              style: AppTheme.textTheme.titleMedium,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Pas encore de compte ?',
                                style: AppTheme.textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.textDark.withOpacity(0.7),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Get.toNamed(AppRoutes.signup),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.primaryBrown,
                                ),
                                child: Text(
                                  'Créer un compte',
                                  style: AppTheme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_authController.isLoading.value)
            Container(
              color: Colors.black12,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBrown.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBrown),
                  ),
                ),
              ),
            ),
        ],
      )),
    );
  }
}
