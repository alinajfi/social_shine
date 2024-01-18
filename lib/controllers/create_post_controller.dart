import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/firebase_constants.dart';

class CreatePostController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  File? imageFile;

  Future<List<String>> uploadImages(List<XFile>? pickedFiles) async {
    List<String> downloadUrls = [];

    for (XFile pickedFile in pickedFiles!) {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('post_images')
            .child('${pickedFile.name}.jpg');

        await ref.putFile(File(pickedFile.path));
        String url = await ref.getDownloadURL();
        downloadUrls.add(url);
      } on FirebaseException catch (e) {
        log(e.toString());
      }
    }
    return downloadUrls;
  }

  getFromGallery() async {
    var pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      imageFile = File(file.path);
    }
  }

  Future<bool> isUserAdmin(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection(FirebaseConstants.userCollection)
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final role = userDoc.get('role');
        return role == 'admin';
      }
    } catch (error) {
      log('Error checking user role: $error');
    }
    return false;
  }
}
