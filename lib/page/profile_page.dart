import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import '../theme/app_theme.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/product_model.dart';
import '../routes/app_routes.dart';
import 'chat_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImageFile;
  final ImagePicker _picker = ImagePicker();
  final ProfileController profileController = Get.put(ProfileController());
  final AuthController authController = Get.find<AuthController>();
  final FavoritesController favoritesController = Get.find();
  bool isEditingName = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (authController.firebaseUser.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.login);
      });
    } else {
      profileController.loadUserData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceActionSheet() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SizedBox(
        height: 160,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Colors.brown),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.brown),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
      profileController.setProfileImage(_profileImageFile!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = authController.firebaseUser.value;
      
      if (user == null) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: 100,
                  color: AppTheme.primaryBrown.withOpacity(0.5),
                ),
                const SizedBox(height: 20),
                Text(
                  'Connectez-vous pour voir votre profil',
                  style: AppTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryBrown,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.login),
                  style: AppTheme.primaryButtonStyle,
                  child: const Text('Se connecter'),
                ),
              ],
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppTheme.primaryBrown),
          title: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                AppTheme.accentGold,
                AppTheme.primaryBrown.withOpacity(0.8),
                AppTheme.accentGold,
              ],
            ).createShader(bounds),
            child: Text(
              'Mon Profil',
              style: AppTheme.textTheme.displayMedium?.copyWith(
                fontFamily: 'Playfair Display',
                fontSize: 24,
                letterSpacing: 1.2,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: AppTheme.primaryBrown),
              onPressed: () async {
                await authController.logout();
                Get.offAllNamed(AppRoutes.login);
              },
            ),
          ],
        ),
        body: Obx(() {
          if (profileController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final userData = profileController.userData.value;
          if (userData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.primaryBrown.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Impossible de charger les données',
                    style: AppTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => profileController.loadUserData(),
                    style: AppTheme.primaryButtonStyle,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _addressController.text = userData['address'] ?? '';

          return Container(
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryBrown.withOpacity(0.1),
                          AppTheme.accentGold.withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryBrown.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 75,
                                backgroundColor: AppTheme.surfaceLight,
                                child: CircleAvatar(
                                  radius: 70,
                                  backgroundImage: _profileImageFile != null
                                      ? FileImage(_profileImageFile!)
                                      : null,
                                  child: _profileImageFile == null
                                      ? Icon(
                                          Icons.person,
                                          size: 70,
                                          color: AppTheme.primaryBrown,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 4,
                              child: GestureDetector(
                                onTap: _showImageSourceActionSheet,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryBrown.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        isEditingName
                            ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40),
                                child: Column(
                                  children: [
                                    _buildInputFields(),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              isEditingName = false;
                                            });
                                          },
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          ),
                                          child: Text(
                                            'Annuler',
                                            style: AppTheme.textTheme.bodyLarge?.copyWith(
                                              color: AppTheme.primaryBrown,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              await profileController.updateUserData(
                                                name: _nameController.text,
                                                email: _emailController.text,
                                                phone: _phoneController.text,
                                                address: _addressController.text,
                                              );
                                              setState(() {
                                                isEditingName = false;
                                              });
                                            } catch (e) {
                                              Get.snackbar(
                                                'Erreur',
                                                'Impossible de mettre à jour les informations',
                                                backgroundColor: Colors.red.shade100,
                                              );
                                            }
                                          },
                                          style: AppTheme.primaryButtonStyle.copyWith(
                                            padding: MaterialStateProperty.all(
                                              const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                            ),
                                          ),
                                          child: Text(
                                            'Enregistrer',
                                            style: AppTheme.textTheme.bodyLarge?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isEditingName = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceLight,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: AppTheme.accentGold.withOpacity(0.3),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryBrown.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            userData['name'] ?? 'Nom non défini',
                                            style: AppTheme.textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryBrown,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppTheme.accentGold.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.edit,
                                              size: 16,
                                              color: AppTheme.accentGold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        userData['email'] ?? 'Email non défini',
                                        style: AppTheme.textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.primaryBrown.withOpacity(0.7),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentGold.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Text(
                                          userData['role'] == 'artisan' ? 'Artisan' : 'Client',
                                          style: AppTheme.textTheme.bodySmall?.copyWith(
                                            color: AppTheme.accentGold,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildUserInfoSection(userData),
                  const SizedBox(height: 30),
                  _buildOrdersSection(),
                  const SizedBox(height: 30),
                  _buildSection(
                    title: 'Mes Favoris',
                    content: Obx(() {
                      final favorites = favoritesController.favorites;
                      if (favorites.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text('Aucun favori pour le moment'),
                          ),
                        );
                      }
                      return SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            final product = favorites[index];
                            return Container(
                              width: 160,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryBrown.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                        child: Image.network(
                                          product.image,
                                          height: 120,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: AppTheme.textTheme.titleSmall?.copyWith(
                                            color: AppTheme.primaryBrown,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${product.price} TND',
                                          style: AppTheme.textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.accentGold,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 30),
                  if (userData['role'] == 'client') ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.to(() => const ChatPage());
                        },
                        icon: const Icon(Icons.chat_bubble_outline, size: 24),
                        label: Text(
                          'Contacter un artisan',
                          style: AppTheme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: AppTheme.primaryButtonStyle.copyWith(
                          minimumSize: MaterialStateProperty.all(const Size(double.infinity, 55)),
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        }),
      );
    });
  }

  Widget _buildSection({required String title, required Widget content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                AppTheme.accentGold,
                AppTheme.primaryBrown,
                AppTheme.accentGold.withOpacity(0.8),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds),
            child: Text(
              title,
              style: AppTheme.textTheme.displayMedium?.copyWith(
                fontFamily: 'Playfair Display',
                fontSize: 24,
                letterSpacing: 0.8,
                height: 1.3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildUserInfoSection(Map<String, dynamic> userData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations personnelles',
            style: AppTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryBrown,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Téléphone', userData['phone'] ?? 'Non renseigné', Icons.phone),
          const SizedBox(height: 15),
          _buildInfoRow('Adresse', userData['address'] ?? 'Non renseignée', Icons.location_on),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryBrown.withOpacity(0.7), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryBrown.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryBrown,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersSection() {
    return Obx(() {
      final orders = profileController.userOrders;
      
      if (orders.isEmpty) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 48,
                  color: AppTheme.primaryBrown.withOpacity(0.3),
                ),
                const SizedBox(height: 10),
                Text(
                  'Aucune commande pour le moment',
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryBrown.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mes commandes',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryBrown,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      'Commande #${order['id'].substring(0, 8)}',
                      style: AppTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: ${(order['createdAt'] as Timestamp).toDate().toString().substring(0, 16)}',
                          style: AppTheme.textTheme.bodySmall,
                        ),
                        Text(
                          'Statut: ${order['status'] ?? 'En cours'}',
                          style: AppTheme.textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(order['status']),
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      '${order['total']} TND',
                      style: AppTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Livré':
        return Colors.green;
      case 'En cours':
        return Colors.orange;
      case 'Annulé':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        _buildInputField('Nom', _nameController, Icons.person),
        const SizedBox(height: 12),
        _buildInputField('Email', _emailController, Icons.email),
        const SizedBox(height: 12),
        _buildInputField('Téléphone', _phoneController, Icons.phone),
        const SizedBox(height: 12),
        _buildInputField('Adresse', _addressController, Icons.location_on),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: AppTheme.textTheme.bodyLarge?.copyWith(
          color: AppTheme.primaryBrown,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppTheme.surfaceLight,
          labelText: label,
          labelStyle: TextStyle(color: AppTheme.primaryBrown.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: AppTheme.primaryBrown.withOpacity(0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppTheme.primaryBrown.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppTheme.accentGold, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }
}
