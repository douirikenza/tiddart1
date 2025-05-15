import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../theme/app_theme.dart';
import '../controllers/favorites_controller.dart';
import '../models/product_model.dart';
import 'chat_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImageFile;
  final ImagePicker _picker = ImagePicker();

  String firstName = 'Kenza';
  String lastName = 'Douiri';
  bool isEditingName = false;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final FavoritesController favoritesController = Get.find();

  @override
  void initState() {
    super.initState();
    _firstNameController.text = firstName;
    _lastNameController.text = lastName;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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
    }
  }

  @override
  Widget build(BuildContext context) {
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
      ),
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
                                  : const NetworkImage('https://via.placeholder.com/150') as ImageProvider,
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
                                _buildInputField('Prénom', _firstNameController, Icons.person_outline),
                                const SizedBox(height: 12),
                                _buildInputField('Nom', _lastNameController, Icons.person),
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
                                      onPressed: () {
                                        setState(() {
                                          firstName = _firstNameController.text;
                                          lastName = _lastNameController.text;
                                          isEditingName = false;
                                        });
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$firstName $lastName',
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
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildSection(
                title: 'Mes Favoris',
                content: Obx(() {
                  final favorites = favoritesController.favorites;
                  if (favorites.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 48,
                            color: AppTheme.primaryBrown.withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Aucun produit favori",
                            style: AppTheme.textTheme.bodyLarge?.copyWith(
                              color: AppTheme.primaryBrown.withOpacity(0.7),
                            ),
                          ),
                        ],
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
                                    child: Image.asset(
                                      product.image,
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => favoritesController.removeFromFavorites(product.id),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceLight,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                      ),
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
                                      product.price,
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
              _buildSection(
                title: 'Produits en promotion',
                content: _buildPromotionsGrid([
                  {'title': "Huile d'Olive", 'image': 'assets/huile.jpeg', 'price': '18,00 TND'},
                  {'title': 'Poterie artisanale', 'image': 'assets/poterie.jpeg', 'price': '45,00 TND'},
                  {'title': 'Savon naturel', 'image': 'assets/savon.jpeg', 'price': '8,00 TND'},
                  {'title': 'Tapis berbère', 'image': 'assets/tapis.jpeg', 'price': '110,00 TND'},
                ]),
              ),
              const SizedBox(height: 30),
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildPromotionsGrid(List<Map<String, String>> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
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
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  product['image']!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['title']!,
                      style: AppTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.primaryBrown,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['price']!,
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
