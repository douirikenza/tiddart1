import 'dart:io';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  var profileImage = Rx<File?>(null);

  void setProfileImage(File image) {
    profileImage.value = image;
  }
}
