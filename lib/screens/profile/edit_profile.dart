import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_found/models/user_model.dart';


class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final ImagePicker _imagePicker = ImagePicker();
  User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _usernameController = TextEditingController();

  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMapUserRegistration(value.data());
setState(() {
  
});
      _usernameController.text = loggedInUser.fullName!;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
  }

  Widget _buildProfileAvatar() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(500.0),
          child: (loggedInUser.profileImageReference != null)
              ? Image.network(
                  loggedInUser.profileImageReference.toString(),
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.width * 0.4,
                  width: MediaQuery.of(context).size.height * 0.2,
                )
              : Image.asset(
                  "assets/person.png",
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.width * 0.4,
                  width: MediaQuery.of(context).size.height * 0.2,
                ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: CircleAvatar(
            child: IconButton(
              icon: const Icon(
                Icons.edit,
              ),
              onPressed: () {
                _pickImage();
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(user!.uid)
                  .update({"fullName": _usernameController.text}).then((value) => {
                    Fluttertoast.showToast(msg: "Username updated")

                  }).onError((error, stackTrace) =>{
                    Fluttertoast.showToast(msg: "Failed to update username")
            });
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildProfileAvatar(),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    final XFile? pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      // Update the user's profile picture locally

      // Update the user's profile picture in Firebase
      await _updateUserProfilePicture(File(pickedImage.path));

      // You can also show a toast or message indicating the profile picture has been updated.
    }
  }

  Future<void> _updateUserProfilePicture(File newProfilePicture) async {
    // Upload the new profile picture to Firebase Storage
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('${FirebaseAuth.instance.currentUser?.uid}.jpg');
    await ref.putFile(newProfilePicture);
    final url = await ref.getDownloadURL();

    // Update the profile image reference in Firestore
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
      "profileImage": url,
    }).then((value) => {Fluttertoast.showToast(msg: "Profile picture updated"),
      Navigator.pop(context) 
    }).onError((error, stackTrace) => 
    {Fluttertoast.showToast(msg: "Failed to update profile picture")});

    // You can also show a toast or message indicating the profile picture has been updated.
  }
}
