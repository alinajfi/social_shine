// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lost_found/screens/auth/login_screen.dart';
import 'package:lost_found/screens/profile/change_password.dart';
import 'package:lost_found/screens/profile/edit_profile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .1,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(500.0),
                child: (loggedInUser.profileImageReference != null)
                    ? Image.network(
                        loggedInUser.profileImageReference.toString(),
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.width * 0.4,
                        width: MediaQuery.of(context).size.height * 0.2,
                      )
                    : const Icon(
                        Icons.image,
                        size: 25,
                      ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .03,
              ),
              Text(
                  loggedInUser.fullName.toString().isEmpty
                      ? ""
                      : loggedInUser.fullName.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.normal, fontSize: 15)),
              Text(loggedInUser.email.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                      color: Colors.grey)),
              SizedBox(
                height: MediaQuery.of(context).size.height * .03,
              ),
              const Divider(
                height: 1,
                color: Colors.grey,
              ),
              editProfile(
                context,
                "Edit Profile",
              ),
              const Divider(
                height: 1,
                color: Colors.grey,
              ),
              const Divider(
                height: 1,
                color: Colors.grey,
              ),
              changePassword(
                context,
                "Change Password",
              ),
              const Divider(
                height: 1,
                color: Colors.grey,
              ),
              const Divider(
                height: 1,
                color: Colors.grey,
              ),
              buildAccount(
                context,
                "Terms of Service",
              ),
              const Divider(
                height: 1,
                color: Colors.grey,
              ),
              const Divider(
                height: 1,
                color: Colors.grey,
              ),
              buildAccount(
                context,
                "Privacy Policy",
              ),
              const Divider(
                height: 1,
                color: Colors.grey,
              ),
              const Divider(
                height: 1,
                color: Colors.grey,
              ),
              buildLogout(
                context,
                "Logout",
              ),
              const Divider(
                height: 1,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL() async {
    String googleAccountSettingsURL = 'https://myaccount.google.com/security';

    if (await canLaunchUrl(Uri.parse(googleAccountSettingsURL))) {
      await launchUrl(Uri.parse(googleAccountSettingsURL));
    } else {
      throw 'Could not launch $googleAccountSettingsURL';
    }
  }

  GestureDetector buildAccount(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
            const SizedBox(
              width: 19,
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black,
            )
          ],
        ),
      ),
    );
  }

  GestureDetector changePassword(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        if (user != null) {
          for (UserInfo userInfo in user!.providerData) {
            if (userInfo.providerId == 'google.com') {
              _launchURL();
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChangePassword()));
            }
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
            const SizedBox(
              width: 19,
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black,
            )
          ],
        ),
      ),
    );
  }

  GestureDetector editProfile(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {

         if (user != null) {
          for (UserInfo userInfo in user!.providerData) {
            if (userInfo.providerId == 'google.com') {
              _launchURL();
            } else {
              Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const EditProfile(),
            ));
            }
          }
        }
        
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
            const SizedBox(
              width: 19,
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black,
            )
          ],
        ),
      ),
    );
  }

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (Route<dynamic> route) => false);
  }

  GestureDetector buildLogout(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        logout(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
            const SizedBox(
              width: 19,
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black,
            )
          ],
        ),
      ),
    );
  }
}
