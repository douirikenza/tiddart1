import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/artisan.dart';

class ArtisanController extends GetxController {
  Rx<Artisan?> artisan = Rx<Artisan?>(null);

  Future<void> fetchArtisan(String artisanId) async {
    final doc = await FirebaseFirestore.instance.collection('artisans').doc(artisanId).get();
    if (doc.exists) {
      artisan.value = Artisan.fromMap(doc.id, doc.data()!);
    }
  }
} 