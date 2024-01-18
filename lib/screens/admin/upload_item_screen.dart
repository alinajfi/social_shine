// ignore_for_file: avoid_print, use_build_context_synchronously, unused_local_variable

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_found/models/item_model.dart';

class UploadItemScreen extends StatefulWidget {
  const UploadItemScreen({super.key});

  @override
  UploadItemScreenState createState() => UploadItemScreenState();
}

class UploadItemScreenState extends State<UploadItemScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController itemStatusController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Lost and Found Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              MaterialButton(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                minWidth: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.35,
                onPressed: () async {
                  await _getFromGallery();
                },
                child: imageFile == null
                    ? const Icon(
                        Icons.upload,
                        size: 150,
                        color: Colors.black,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(0.0),
                        child: Image.file(
                          imageFile!,
                          fit: BoxFit.fitHeight,
                          height: MediaQuery.of(context).size.width / 2,
                          width: MediaQuery.of(context).size.height * 0.45,
                        ),
                      ),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Details'),
              ),
              // TextField(
              //   controller: itemStatusController,
              //   decoration: const InputDecoration(labelText: 'Item Status'),
              // ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Call the function to upload the item
                  uploadItem(
                    nameController.text,
                    locationController.text,
                    itemStatusController.text,
                  );
                },
                child: const Text('Upload Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> uploadImageToFirebase(
      File imageFile, String imageName) async {
    try {
      // Reference to a Firebase Storage location
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('images/$imageName');

      // Upload the file to Firebase Storage
      final UploadTask uploadTask = storageReference.putFile(imageFile);

      // Await the completion of the upload task
      await uploadTask;

      // Get the download URL from the uploaded image
      final imageUrl = await storageReference.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null; // Handle the error as needed
    }
  }

  //Get from gallery
  String? url;
  File? imageFile;
  XFile? pickedFile;

  _getFromGallery() async {
    pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() async {
        File file = File(pickedFile!.path);
        imageFile = File('${pickedFile?.path}');
      });
    }
  }

  String getUniqueId() {
    return "${FirebaseAuth.instance.currentUser!.uid.hashCode + DateTime.now().microsecondsSinceEpoch}";
  }

  Future<void> uploadItem(
      String name, String location, String itemStatus) async {
    try {
      // _getFromGallery();
      // Perform your item upload logic here, such as saving it to a database.
      // For example, if you're using Firebase Firestore:
      final imageUrl =
          await uploadImageToFirebase(imageFile!, '${getUniqueId()}.jpg');

      if (imageUrl != null) {
        // The image was uploaded successfully, and imageUrl contains the download URL.
        // You can now associate this URL with your ItemModel or store it in Firestore.
      } else {
        // Handle the case where the image upload failed.
      }
      await FirebaseFirestore.instance
          .collection('lost_and_found_items')
          .add(ItemModel(
            name: name,
            location: location,
            itemStatus: "Lost",
            favouritesList: [],
            time: DateTime.now(),
            imageUrl: imageUrl!,
          ).toJson());

      Navigator.pop(context);

      // Show a success message or navigate to another screen.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item uploaded successfully!'),
        ),
      );

      // Clear the text fields after successful upload.
      nameController.clear();
      locationController.clear();
      itemStatusController.clear();
    } catch (e) {
      // Handle any errors that occur during the upload.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading item: $e'),
        ),
      );
    }
  }
}
