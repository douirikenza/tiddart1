import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final uuid = const Uuid();

  Future<dynamic> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return null;
      
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        return bytes;
      } else {
        return File(image.path);
      }
    } catch (e) {
      debugPrint('Erreur lors de la sélection de l\'image: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de sélectionner l\'image. Veuillez réessayer.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    }
  }

  Future<String?> uploadImage(dynamic imageData, String folder) async {
    try {
      if (kIsWeb) {
        // Pour le web, nous convertissons l'image en base64
        final Uint8List bytes = imageData as Uint8List;
        if (bytes.length > 5 * 1024 * 1024) {
          throw Exception('L\'image est trop volumineuse (max 5MB)');
        }
        final base64Image = base64Encode(bytes);
        return 'data:image/jpeg;base64,$base64Image';
      } else {
        // Pour mobile/desktop, nous copions l'image dans le dossier de l'application
        final File imageFile = imageData as File;
        final fileSize = await imageFile.length();
        if (fileSize > 5 * 1024 * 1024) {
          throw Exception('L\'image est trop volumineuse (max 5MB)');
        }

        // Créer le dossier s'il n'existe pas
        final appDir = await getApplicationDocumentsDirectory();
        final categoryDir = Directory('${appDir.path}/$folder');
        if (!await categoryDir.exists()) {
          await categoryDir.create(recursive: true);
        }

        // Copier l'image dans le dossier de l'application
        final fileName = '${uuid.v4()}.jpg';
        final savedImage = await imageFile.copy('${categoryDir.path}/$fileName');
        
        return savedImage.path;
      }
    } catch (e) {
      debugPrint('Erreur lors du traitement de l\'image: $e');
      String errorMessage = 'Impossible de traiter l\'image.';
      
      if (e.toString().contains('trop volumineuse')) {
        errorMessage = 'L\'image est trop volumineuse (max 5 Mo). Veuillez choisir une image plus petite.';
      }
      
      Get.snackbar(
        'Erreur',
        errorMessage,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 8),
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.error, color: Colors.white, size: 32),
        titleText: const Text('Erreur', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        messageText: Text(
          errorMessage,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
      );
      return null;
    }
  }

  Future<void> showImagePickerDialog(BuildContext context, Function(dynamic) onImageSelected) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Sélectionner une image',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.blue.shade700),
                ),
                title: const Text('Prendre une photo'),
                subtitle: const Text('Utiliser l\'appareil photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await pickImage(ImageSource.camera);
                  if (image != null) {
                    onImageSelected(image);
                  }
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.photo_library, color: Colors.green.shade700),
                ),
                title: const Text('Choisir depuis la galerie'),
                subtitle: const Text('Sélectionner une image existante'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await pickImage(ImageSource.gallery);
                  if (image != null) {
                    onImageSelected(image);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
} 