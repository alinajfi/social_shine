// ignore_for_file: avoid_print, unused_local_variable, unused_element

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_found/utils/firebase_constants.dart';

import '../../models/user_model.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              "Create Post",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                children: [
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(0),
                    color: Colors.white,
                    child: GestureDetector(
                        onTap: () async {
                          await _getFromGalleryV1();
                        },
                        child: Column(
                          children: [
                            pickedFilesV1 == null
                                ? Image.asset(
                                    "assets/icon.jpeg",
                                    // color: Colors.black,
                                  )
                                : SizedBox(
                                    child: StaggeredGrid.count(
                                      crossAxisCount: 1, // Vertical spacing
                                      crossAxisSpacing:
                                          4.0, // Number of columns
                                      children: pickedFilesV1!
                                          .map((e) => Container(
                                                margin:
                                                    const EdgeInsets.all(4.0),
                                                // Adjust the margin as needed
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0), // Rounded corners
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: Image.file(
                                                    File(e.path),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ))
                                          .toList(), // Horizontal spacing
                                    ),
                                  ),
                          ],
                        )),
                  ),
                ],
              ),
            ),
            TextField(
              minLines: 5,
              maxLines: 10,
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              width: 250,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFEFBA52),
                    Color(0xFFFAA740)
                  ], // Two colors for the gradient
                ),
              ),
              child: MaterialButton(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onPressed: () async {
                  await postDetailsToFirestore();
                },
                child: const Text(
                  'Post',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Get from gallery
  String? url;
  File? imageFile;
  XFile? pickedFile;

  List<XFile>? pickedFilesV1;

  Future<XFile?> _compressImage(File? imageFile) async {
    if (imageFile == null) return null;

    final result = await FlutterImageCompress.compressAndGetFile(
      imageFile.path,
      imageFile.path,
      quality: 50, // Adjust the quality (0 - 100) as needed
    );

    return result;
  }

  Future<CroppedFile?> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper.platform.cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [CropAspectRatioPreset.square],
    );

    return croppedFile;
  }

  _getFromGalleryV1() async {
    List<XFile> pickedFiles = [];
    List<CroppedFile> croppedImages = [];

    try {
      pickedFiles = await ImagePicker().pickMultiImage(imageQuality: 50);

      //create cropped images from picked files
      // for (var pickedFile in pickedFiles) {
      //   File file = File(pickedFile.path);
      //   CroppedFile? croppedFile = await _cropImage(file);
      //   if (croppedFile != null) {
      //     croppedImages.add(croppedFile);
      //   }
      // }

      //convert cropped images to XFile
      // pickedFiles = [];
      // for (var croppedImage in croppedImages) {
      //   File file = File(croppedImage.path);
      //   XFile xFile = XFile(file.path);
      //   pickedFiles.add(xFile);
      // }
    } on Exception catch (e) {
      // Handle any exceptions (e.g., permission denied).
      log(e.toString());
    }

    if (pickedFiles.isNotEmpty) {
      List<XFile> files = [];
      for (var pickedFile in pickedFiles) {
        files.add(pickedFile);
      }

      setState(() {
        pickedFilesV1 = files;
      });
    }
  }

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
      } on FirebaseException catch (e, s) {
        debugPrintStack(label: e.toString(), stackTrace: s);
      }
    }
    return downloadUrls;
  }

  _getFromGallery() async {
    pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        File file = File(pickedFile!.path);
        imageFile = File('${pickedFile?.path}');
      });
    }
  }

  final _auth = FirebaseAuth.instance;
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
      print('Error checking user role: $error');
    }
    return false; // Return false if user not found or there's an error
  }

  Future<void> postDetailsToFirestore() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    UserModel userModel = UserModel();
    print("Testing role##########");
    print(loggedInUser.role);
    // final ref = FirebaseStorage.instance
    //     .ref()
    //     .child('post_images')
    //     .child('asdasd.jpg');
    // await ref.putFile(imageFile!);
    // url = await ref.getDownloadURL();

    final images = await uploadImages(pickedFilesV1);

    userModel.description = descriptionController.text;
    userModel.postImage = url;
    userModel.postImages = images;
    userModel.profileImageReference = loggedInUser.profileImageReference;
    userModel.timestamp = DateTime.now();
    userModel.likes = [];
    userModel.uid = FirebaseAuth.instance.currentUser?.uid;

    await firebaseFirestore
        .collection(loggedInUser.role == "admin" ? "admin_post" : "posts")
        .doc()
        .set(userModel.toMapPost());
    descriptionController.text = '';
    setState(() {
      imageFile = null;
      pickedFilesV1 = null;
    });
    Fluttertoast.showToast(
        msg: loggedInUser.role == "admin"
            ? "Admin Post has been posted successfully!"
            : "Your Post has been posted successfully!");
  }

  User? user = FirebaseAuth.instance.currentUser;
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
      setState(() {});
    });
  }
}
