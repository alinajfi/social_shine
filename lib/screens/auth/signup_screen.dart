// ignore_for_file: unused_local_variable, body_might_complete_normally_catch_error, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_found/screens/auth/login_screen.dart';

import '../../models/user_model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isHidden = false;
  void togglePasswordView() {
    setState(() {
      isHidden = !isHidden;
    });
  }

  bool isHidden1 = false;
  void togglePasswordView1() {
    setState(() {
      isHidden1 = !isHidden1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Create Account",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                  child: Column(
                    children: [
                      Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(80),
                        color: Colors.white,
                        child: MaterialButton(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          minWidth: MediaQuery.of(context).size.width * 0.26,
                          height: MediaQuery.of(context).size.height * 0.13,
                          onPressed: () async {
                            await _getFromGallery();
                          },
                          child: Column(
                            children: [
                              imageFile == null
                                  ? const CircleAvatar(
                                      radius: 48,
                                      // child: Icon(
                                      //   Icons.person,
                                      //   size: 85,
                                      //   // fit: BoxFit.cover,
                                      //   // height:
                                      //   //     MediaQuery.of(context).size.width *
                                      //   //         0.26,
                                      //   // width:
                                      //   //     MediaQuery.of(context).size.height *
                                      //   //         0.13,
                                      // ),
                                      backgroundImage: AssetImage(
                                        "assets/icon.jpeg",
                                        // fit: BoxFit.cover,
                                        // height:
                                        //     MediaQuery.of(context).size.width *
                                        //         0.26,
                                        // width:
                                        //     MediaQuery.of(context).size.height *
                                        //         0.13,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(0.0),
                                      child: Image.file(
                                        imageFile!,
                                        fit: BoxFit.cover,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.26,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                0.13,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: isHidden,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffix: InkWell(
                      onTap: togglePasswordView,
                      child: Icon(
                        isHidden ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                    ), // Toggle password visibility
                  ),
                ),
                TextField(
                  obscureText: isHidden1,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffix: InkWell(
                      onTap: togglePasswordView1,
                      child: Icon(
                        isHidden1 ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  width: 250,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
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
                      await signUp(
                          emailController.text, passwordController.text);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()));
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?  "),
                    GestureDetector(
                      onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()))
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(color: Color(0xFFEFBA52)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
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
      // setState(() async {
      File file = File(pickedFile!.path);
      imageFile = File('${pickedFile?.path}');
      //final url1 = await storage.ref('DonorProfileImage/$pickedFile?.name').putFile(file);
      setState(() {});
      //StorageModel storageModel = StorageModel();
      //storageModel.uploadDonorImage(pickedFile?.path, pickedFile?.name);
      // });
    }
  }

  final _auth = FirebaseAuth.instance;
  Future<void> postDetailsToFirestore() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    UserModel userModel = UserModel();
    // writing all the values
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('${user?.uid}.jpg');
    await ref.putFile(imageFile!);
    url = await ref.getDownloadURL();
    userModel.email = emailController.text;
    userModel.password = passwordController.text;
    userModel.fullName = fullNameController.text;
    userModel.timestamp = DateTime.now();
    userModel.likes = [];
    userModel.profileImageReference = url;
    await firebaseFirestore
        .collection("users")
        .doc(user?.uid)
        .set(userModel.toMapUserRegistration());
    Fluttertoast.showToast(msg: "Your account has been created successfully");
  }

  Future<void> signUp(String email, String password) async {
    await _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) async => {await postDetailsToFirestore()})
        .catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }
}
