// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lost_found/models/user_model.dart';
import 'package:lost_found/screens/admin/admin_login_screen.dart';
import 'package:lost_found/screens/home/home_screen.dart';
import 'package:lost_found/screens/auth/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isHidden = false;
  final key = GlobalKey<FormState>();
  void togglePasswordView() {
    setState(() {
      isHidden = !isHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              const Text(
                "LOGIN",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
              const Text(
                "Please sign in to continue",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 12),
              ),
              Form(
                key: key,
                child: TextFormField(
                  controller: emailController,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Email is required";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  // suffix: InkWell(
                  //   onTap: togglePasswordView,
                  //   child: Icon(
                  //     isHidden ? Icons.visibility : Icons.visibility_off,
                  //     color: Colors.grey,
                  //   ),
                  // ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        if (key.currentState!.validate()) {
                          sendPasswordResetEmail(emailController.text.trim());
                        }
                      },
                      child: const Text(
                        "Forgot Password",
                        style: TextStyle(color: Color(0xFFEFBA52)),
                      ))
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: 250,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFEFBA52), Color(0xFFFAA740)],
                  ),
                ),
                child: MaterialButton(
                  elevation: 3.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () {
                    signIn(emailController.text, passwordController.text);
                  },
                  child: const Text(
                    'Login',
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Color(0xFFEFBA52)),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(children: [
                Expanded(
                  child: Container(
                      margin: const EdgeInsets.only(left: 25.0, right: 15.0),
                      child: const Divider(
                        color: Colors.grey,
                      )),
                ),
                const Text(
                  "OR",
                  style: TextStyle(color: Colors.black),
                ),
                Expanded(
                  child: Container(
                      margin: const EdgeInsets.only(left: 15.0, right: 25.0),
                      child: const Divider(
                        color: Colors.grey,
                      )),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.only(left: 70.0),
                child: InkWell(
                  onTap: () {
                    signInWithGoogle();
                  },
                  child: ListTile(
                    horizontalTitleGap: 8,
                    leading: Image.asset(
                      "assets/google.png",
                      height: 30.0,
                      width: 30.0,
                    ),
                    title: const Text("Login with google"),
                  ),
                ),
              ),

              const Spacer(),
              // Add a "Login as admin" button
              Container(
                width: 250,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFEFBA52), Color(0xFFFAA740)],
                  ),
                ),
                child: MaterialButton(
                  elevation: 3.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () {
                    // Navigate to admin login screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminLoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Login as admin',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Send a password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      Fluttertoast.showToast(msg: "PLease Wait");
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      Fluttertoast.showToast(
          msg: "Password Reset Email has been sent on the email provided");
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString());
    }
  }

  // login function
  void signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      Fluttertoast.showToast(msg: "Login Successful");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Login is not successful");
    }
  }
  
Future<void> signInWithGoogle() async {
  try {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Sign in with Google
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // Check if the user is already registered in Firestore
    final User? user = userCredential.user;
    final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection("users").doc(user?.uid).get();

    if (!userDoc.exists) {
      // If the user doesn't exist in Firestore, create a new profile
      UserModel userModel = UserModel();
      userModel.email = user?.email ?? "";
      userModel.fullName = user?.displayName ?? "";
      userModel.timestamp = DateTime.now();
      userModel.likes = [];
      userModel.profileImageReference = user?.photoURL ?? "";

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user?.uid)
          .set(userModel.toMapUserRegistration());
    }

    Fluttertoast.showToast(msg: "Login Successful");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  } catch (e) {
    Fluttertoast.showToast(msg: "Login is not successful");
  }
}

}
