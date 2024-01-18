import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';

class SavePostScreen extends StatefulWidget {
  const SavePostScreen({Key? key}) : super(key: key);
  @override
  State<SavePostScreen> createState() => _SavePostScreenState();
}

class _SavePostScreenState extends State<SavePostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bookmark',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {
              // Handle search button click
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .collection('bookmark')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (streamSnapshot.connectionState ==
                ConnectionState.active) {
              final product = streamSnapshot.data?.docs;
              if (product == null || product.isEmpty) {
                return const Center(child: Text('No Restaurants'));
              } else {
                return SingleChildScrollView(
                  child: Column(children: [
                    for (var data in product)
                      FutureBuilder<String>(
                          future: null,
                          builder: (_, imageSnapshot) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width * .95,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      width: 70,
                                      height: 70,
                                      decoration: const BoxDecoration(
                                          color: Color(0xFFffffff),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(0))),
                                      child: Image(
                                        image:
                                            NetworkImage(data['profileImage']),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                1,
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "@${loggedInUser.fullName}",
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 15),
                                      ),
                                      const Text(
                                        'Your dynamic text goes here.\nThis text can be long\nand will wrap to the next\nline if it exceeds the available\nspace.',
                                        maxLines: 5,
                                        overflow: TextOverflow.fade,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Image(
                                        image: NetworkImage(data['postImage']),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .6,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .1,
                    )
                  ]),
                );
              }
            } else {
              return const Center(
                child: Text(
                  'FATAL ERROR',
                ),
              );
            }
          },
        ),
      ),
    );
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
