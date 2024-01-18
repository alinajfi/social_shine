// ignore_for_file: body_might_complete_normally_catch_error

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lost_found/screens/home/home_screen.dart';
import 'package:lost_found/screens/auth/signup_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
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
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Admin Login",
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
                  // ), // Toggle password visibility
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
              const SizedBox(height: 20),
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
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupScreen())),
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Color(0xFFEFBA52)),
                    ),
                  ),
                ],
              )
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
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((uid) => {
              Fluttertoast.showToast(msg: "Login Successful"),
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const HomeScreen())),
            })
        .catchError((e) {
      Fluttertoast.showToast(msg: "Login is not successful");
    });
  }
}
