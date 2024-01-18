import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  Future<void> _changePassword(context) async {
    if (_newPasswordController.text == _confirmPasswordController.text) {
      try {
        // Reauthenticate the user with their old password.
        final AuthCredential credential = EmailAuthProvider.credential(
          email: _user!.email!,
          password: _oldPasswordController.text,
        );
        await _user!.reauthenticateWithCredential(credential);

        // Change the password.
        await _user!
            .updatePassword(_newPasswordController.text)
            .then((value) => {
                  db
                      .collection("users")
                      .doc(_user!.uid.toString())
                      .update({'password': _newPasswordController.text})
                });

        Fluttertoast.showToast(msg: "Password changed successfully!");

        Navigator.pop(context);
      } catch (e) {
        Fluttertoast.showToast(
            msg: 'Failed to change password. ${e.toString()}');
      }
    } else {
      Fluttertoast.showToast(msg: 'Passwords do not match.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: const Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Old Password'),
            ),
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Confirm New Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _changePassword(context),
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
