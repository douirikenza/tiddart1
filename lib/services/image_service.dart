import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final uuid = const Uuid();

  Future<File?> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return null;
      return File(image.path);
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

  Future<String?> uploadImage(File imageFile, String folder) async {
    try {
      // Vérifier la taille de l'image (max 5MB)
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('L\'image est trop volumineuse (max 5MB)');
      }

      String fileName = '${uuid.v4()}${path.extension(imageFile.path)}';
      final storageRef = _storage.ref().child('$folder/$fileName');
      
      final uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/${path.extension(imageFile.path).substring(1)}',
          customMetadata: {'picked-file-path': imageFile.path},
        ),
      );

      // Gérer les erreurs pendant le téléchargement
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        switch (snapshot.state) {
          case TaskState.running:
            final progress = 100.0 * (snapshot.bytesTransferred / snapshot.totalBytes);
            debugPrint('Progression du téléchargement : ${progress.toStringAsFixed(2)}%');
            break;
          case TaskState.error:
            throw Exception('Erreur pendant le téléchargement');
          default:
            break;
        }
      });
      
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Erreur lors du téléchargement de l\'image: $e');
      String errorMessage = 'Impossible de télécharger l\'image.';
      
      if (e.toString().contains('trop volumineuse')) {
        errorMessage = 'L\'image est trop volumineuse (max 5MB)';
      } else if (e is FirebaseException) {
        switch (e.code) {
          case 'storage/unauthorized':
            errorMessage = 'Non autorisé à télécharger l\'image';
            break;
          case 'storage/canceled':
            errorMessage = 'Téléchargement annulé';
            break;
          case 'storage/retry-limit-exceeded':
            errorMessage = 'Problème de connexion, veuillez réessayer';
            break;
          default:
            errorMessage = 'Erreur de téléchargement : ${e.message}';
        }
      }
      
      Get.snackbar(
        'Erreur',
        errorMessage,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
      return null;
    }
  }

  Future<void> showImagePickerDialog(BuildContext context, Function(File) onImageSelected) async {
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
                  final File? image = await pickImage(ImageSource.camera);
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
                  final File? image = await pickImage(ImageSource.gallery);
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