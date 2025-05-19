import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_theme.dart';
import '../models/product_model.dart';

class DeliveryFormPage extends StatefulWidget {
  final ProductModel product;

  const DeliveryFormPage({super.key, required this.product});

  @override
  State<DeliveryFormPage> createState() => _DeliveryFormPageState();
}

class _DeliveryFormPageState extends State<DeliveryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _additionalInfoController = TextEditingController();
  
  final double _deliveryFee = 7.0;
  bool _isLocationSelected = false;
  LatLng? _selectedLocation;
  final LatLng _initialPosition = const LatLng(34.0209, -6.8416); // Rabat, Maroc

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre numéro de téléphone';
    }
    final phoneRegex = RegExp(r'^(?:\+216|0)[0-9]\d{7}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Format invalide (ex: 20123456 ou +21620123456)';
    }
    return null;
  }

  String? _validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Code postal requis';
    }
    if (value.length != 4) {
      return 'Le code postal doit contenir 4 chiffres';
    }
    return null;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Les services de localisation sont désactivés.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Les permissions de localisation ont été refusées');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Les permissions de localisation sont définitivement refusées, nous ne pouvons pas demander les permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _showLocationPicker() async {
    try {
      final Position position = await _determinePosition();
      final currentLocation = LatLng(position.latitude, position.longitude);
      
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBrown.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBrown.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrown.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sélectionnez votre localisation',
                          style: AppTheme.textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryBrown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: AppTheme.primaryBrown),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: currentLocation,
                        zoom: 15,
                      ),
                      onTap: (LatLng location) {
                        setState(() {
                          _selectedLocation = location;
                        });
                      },
                      markers: _selectedLocation != null
                          ? {
                              Marker(
                                markerId: const MarkerId('selected_location'),
                                position: _selectedLocation!,
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueOrange,
                                ),
                              ),
                            }
                          : {},
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: true,
                      mapType: MapType.normal,
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_selectedLocation != null) {
                            setState(() {
                              _isLocationSelected = true;
                            });
                            Navigator.pop(context);
                          } else {
                            Get.snackbar(
                              'Attention',
                              'Veuillez sélectionner un point sur la carte',
                              backgroundColor: AppTheme.surfaceLight,
                              colorText: AppTheme.primaryBrown,
                              snackPosition: SnackPosition.TOP,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 10,
                              duration: const Duration(seconds: 2),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBrown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 2,
                        ).copyWith(
                          backgroundColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.pressed)) {
                              return AppTheme.primaryBrown.withOpacity(0.9);
                            }
                            return AppTheme.primaryBrown;
                          }),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline),
                            const SizedBox(width: 8),
                            Text(
                              'Confirmer la localisation',
                              style: AppTheme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString(),
        backgroundColor: AppTheme.surfaceLight,
        colorText: AppTheme.primaryBrown,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productPrice = widget.product.getPriceAsDouble();
    final total = productPrice + _deliveryFee;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryBrown),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Informations de livraison',
          style: AppTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.primaryBrown,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Résumé de la commande
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBrown.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            color: AppTheme.primaryBrown,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Résumé de la commande',
                            style: AppTheme.textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryBrown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPriceRow(
                        'Produit',
                        '${productPrice.toStringAsFixed(2)} TND',
                      ),
                      const SizedBox(height: 8),
                      _buildPriceRow(
                        'Frais de livraison',
                        '${_deliveryFee.toStringAsFixed(2)} TND',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(),
                      ),
                      _buildPriceRow(
                        'Total',
                        '${total.toStringAsFixed(2)} TND',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Sélection de la localisation
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isLocationSelected 
                          ? AppTheme.accentGold
                          : AppTheme.primaryBrown.withOpacity(0.1),
                      width: _isLocationSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBrown.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _isLocationSelected
                                  ? AppTheme.accentGold.withOpacity(0.1)
                                  : AppTheme.primaryBrown.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: _isLocationSelected
                                  ? AppTheme.accentGold
                                  : AppTheme.primaryBrown,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Votre localisation',
                                style: AppTheme.textTheme.titleMedium?.copyWith(
                                  color: AppTheme.primaryBrown,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _isLocationSelected
                                    ? 'Localisation sélectionnée'
                                    : 'Sélectionnez votre position',
                                style: AppTheme.textTheme.bodyMedium?.copyWith(
                                  color: _isLocationSelected
                                      ? AppTheme.accentGold
                                      : AppTheme.primaryBrown.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _showLocationPicker,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isLocationSelected
                              ? AppTheme.accentGold
                              : AppTheme.primaryBrown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ).copyWith(
                          backgroundColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.pressed)) {
                              return _isLocationSelected
                                  ? AppTheme.accentGold.withOpacity(0.9)
                                  : AppTheme.primaryBrown.withOpacity(0.9);
                            }
                            return _isLocationSelected
                                ? AppTheme.accentGold
                                : AppTheme.primaryBrown;
                          }),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isLocationSelected
                                  ? Icons.edit_location
                                  : Icons.add_location,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isLocationSelected
                                  ? 'Modifier la localisation'
                                  : 'Choisir sur la carte',
                              style: AppTheme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Informations personnelles
                _buildSectionTitle('Informations personnelles', Icons.person_outline),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _nameController,
                  label: 'Nom complet',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    if (value.length < 3) {
                      return 'Le nom doit contenir au moins 3 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _phoneController,
                  label: 'Numéro de téléphone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),
                const SizedBox(height: 24),

                _buildSectionTitle('Adresse de livraison', Icons.location_on_outlined),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _addressController,
                  label: 'Adresse',
                  icon: Icons.home_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre adresse';
                    }
                    if (value.length < 10) {
                      return 'Veuillez entrer une adresse plus détaillée';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _cityController,
                        label: 'Ville',
                        icon: Icons.location_city_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ville requise';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _postalCodeController,
                        label: 'Code postal',
                        icon: Icons.markunread_mailbox_outlined,
                        keyboardType: TextInputType.number,
                        validator: _validatePostalCode,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _additionalInfoController,
                  label: 'Instructions supplémentaires (optionnel)',
                  icon: Icons.info_outline,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBrown.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total à payer',
                  style: AppTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryBrown,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${total.toStringAsFixed(2)} TND',
                    style: AppTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.accentGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate() && _isLocationSelected) {
                  Get.snackbar(
                    'Succès',
                    'Votre commande a été enregistrée avec succès',
                    backgroundColor: AppTheme.surfaceLight,
                    colorText: AppTheme.primaryBrown,
                    snackPosition: SnackPosition.TOP,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 10,
                    duration: const Duration(seconds: 2),
                    icon: Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.primaryBrown,
                    ),
                  );
                  Get.offAllNamed('/home');
                } else if (!_isLocationSelected) {
                  Get.snackbar(
                    'Attention',
                    'Veuillez sélectionner votre localisation sur la carte',
                    backgroundColor: AppTheme.surfaceLight,
                    colorText: AppTheme.primaryBrown,
                    snackPosition: SnackPosition.TOP,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 10,
                    duration: const Duration(seconds: 2),
                    icon: Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.accentGold,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 2,
              ).copyWith(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return AppTheme.primaryBrown.withOpacity(0.9);
                  }
                  return AppTheme.primaryBrown;
                }),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline),
                  const SizedBox(width: 8),
                  Text(
                    'Confirmer la commande',
                    style: AppTheme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBrown.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryBrown,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primaryBrown),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppTheme.primaryBrown.withOpacity(0.1),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppTheme.primaryBrown.withOpacity(0.1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppTheme.primaryBrown,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.red.shade300,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.red.shade300,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: AppTheme.surfaceLight,
          labelStyle: TextStyle(
            color: AppTheme.primaryBrown.withOpacity(0.7),
          ),
        ),
        style: AppTheme.textTheme.bodyLarge?.copyWith(
          color: AppTheme.primaryBrown,
        ),
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.textTheme.bodyLarge?.copyWith(
            color: isTotal ? AppTheme.primaryBrown : AppTheme.primaryBrown.withOpacity(0.7),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: AppTheme.textTheme.titleMedium?.copyWith(
            color: isTotal ? AppTheme.accentGold : AppTheme.primaryBrown,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
} 