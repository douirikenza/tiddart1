import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  gmaps.LatLng? _selectedLocation;
  final gmaps.LatLng _initialPosition = const gmaps.LatLng(34.0209, -6.8416); // Rabat, Maroc

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
      final currentLocation = gmaps.LatLng(position.latitude, position.longitude);
      
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
                child: kIsWeb
                    ? _buildWebMap(currentLocation)
                    : Stack(
                        children: [
                          gmaps.GoogleMap(
                            initialCameraPosition: gmaps.CameraPosition(
                              target: currentLocation,
                              zoom: 15,
                            ),
                            onTap: (gmaps.LatLng location) {
                              setState(() {
                                _selectedLocation = location;
                              });
                              _updateAddressFromLatLng(location.latitude, location.longitude);
                            },
                            markers: _selectedLocation != null
                                ? {
                                    gmaps.Marker(
                                      markerId: const gmaps.MarkerId('selected_location'),
                                      position: _selectedLocation!,
                                      icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
                                        gmaps.BitmapDescriptor.hueOrange,
                                      ),
                                    ),
                                  }
                                : {},
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            zoomControlsEnabled: true,
                            mapType: gmaps.MapType.normal,
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

  Widget _buildWebMap(gmaps.LatLng currentLocation) {
    latlng.LatLng? webSelectedLocation = _selectedLocation != null
        ? latlng.LatLng(_selectedLocation!.latitude, _selectedLocation!.longitude)
        : null;
    final mapController = fmap.MapController();

    return StatefulBuilder(
      builder: (context, setState) {
        return Stack(
          children: [
            fmap.FlutterMap(
              mapController: mapController,
              options: fmap.MapOptions(
                initialCenter: webSelectedLocation ?? latlng.LatLng(currentLocation.latitude, currentLocation.longitude),
                initialZoom: 13.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    webSelectedLocation = point;
                    _selectedLocation = gmaps.LatLng(point.latitude, point.longitude);
                  });
                  _updateAddressFromLatLng(point.latitude, point.longitude);
                },
              ),
              children: [
                fmap.TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.app',
                ),
                if (webSelectedLocation != null)
                  fmap.MarkerLayer(
                    markers: [
                      fmap.Marker(
                        width: 40.0,
                        height: 40.0,
                        point: webSelectedLocation!,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  if (webSelectedLocation != null) {
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
        );
      },
    );
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

  Future<void> _updateAddressFromLatLng(double lat, double lng) async {
    try {
      if (kIsWeb) {
        // Utilise Nominatim (OpenStreetMap) sur le web
        final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng&accept-language=fr');
        final response = await http.get(url, headers: {
          'User-Agent': 'FlutterApp/1.0 (your@email.com)'
        });
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final address = data['address'] ?? {};
          setState(() {
            _addressController.text = [
              address['road'],
              address['suburb'],
              address['neighbourhood'],
              address['village'],
              address['town'],
              address['state_district']
            ].where((e) => e != null && e.toString().isNotEmpty).join(', ');
            _cityController.text = address['city'] ?? address['town'] ?? address['village'] ?? address['state'] ?? '';
          });
        } else {
          Get.snackbar(
            'Erreur',
            'Impossible de récupérer l’adresse (Nominatim)',
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
          );
        }
      } else {
        // Utilise geocoding sur mobile
        final placemarks = await geocoding.placemarkFromCoordinates(lat, lng);
        print('Placemarks: $placemarks');
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          setState(() {
            _addressController.text = [
              placemark.street,
              placemark.subLocality,
              placemark.subAdministrativeArea
            ].where((e) => e != null && e.isNotEmpty).join(', ');
            _cityController.text = placemark.locality ?? placemark.administrativeArea ?? '';
          });
        } else {
          Get.snackbar(
            'Adresse introuvable',
            'Aucune adresse n’a été trouvée pour ce point.',
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de récupérer l’adresse : $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      setState(() {
        _addressController.text = '';
        _cityController.text = '';
      });
    }
  }
} 