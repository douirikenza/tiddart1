import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import 'package:http_parser/http_parser.dart'; 


const String cloudinaryCloudName = 'dy1cz1bv5'; 
const String cloudinaryUploadPreset = 'tiddart';


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
      String fileName = '${uuid.v4()}.jpg';
      String cloudName = cloudinaryCloudName;
      String uploadPreset = cloudinaryUploadPreset;

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');

      http.MultipartRequest request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset;


      if (kIsWeb) {
        final Uint8List bytes = imageData as Uint8List;
        if (bytes.length > 10 * 1024 * 1024) {
          throw Exception('L\'image est trop volumineuse (max 10MB)');
        }

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: fileName,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      } else {
        final File imageFile = imageData as File;
        final fileSize = await imageFile.length();
        if (fileSize > 10 * 1024 * 1024) {
          throw Exception('L\'image est trop volumineuse (max 10MB)');
        }
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            imageFile.path,
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        final imageUrl = jsonMap['url'] as String; 
        return imageUrl;
      } else {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        debugPrint('Cloudinary upload failed: $responseString');
        throw Exception('Cloudinary upload failed ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      String errorMessage = 'Failed to upload image.';

      if (e.toString().contains('too large')) {
        errorMessage = 'Image is too large (max 10MB)';
      } else {
        errorMessage = 'Cloudinary upload error: $e';
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
                title: const Text('Take a Photo'),
                subtitle: const Text('Use the camera'),
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
              
                title: const Text('Prendre une photo'),
                subtitle: const Text('Utiliser l\'appareil photo'),
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