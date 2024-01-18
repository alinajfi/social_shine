// ignore_for_file: avoid_print, use_build_context_synchronously, prefer_typing_uninitialized_variables, empty_catches

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lost_found/constant.dart';
import 'package:lost_found/screens/post/save_post_screen.dart';
import 'package:lost_found/utils/firebase_constants.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/user_model.dart';

class SocialHomeScreen extends StatefulWidget {
  const SocialHomeScreen({Key? key}) : super(key: key);

  @override
  State<SocialHomeScreen> createState() => _SocialHomeScreenState();
}

class _SocialHomeScreenState extends State<SocialHomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  int color = 0xFF808080;

  final _commentController = TextEditingController();
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

  Future<bool> isUserAdmin(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
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

  Future<void> addAdminComment(String postId, String comment) async {
    final text = _commentController.text.trim();
    final userId = user?.uid; // Replace with the actual user ID
    final date = DateTime.now();

    if (text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection(FirebaseConstants.adminPostsCollection)
            .doc(postId)
            .collection('comments')
            .add({
          'text': text,
          'user_id': userId,
          'date': date,
          'time': Timestamp.fromDate(date),
          'profileImage': loggedInUser.profileImageReference,
        });
        _commentController.clear();
      } catch (error) {
        print('Error adding comment: $error');
      }
    }
  }

  // Function to add a comment to the post
  Future<void> addComment(String postId, String comment) async {
    final text = _commentController.text.trim();
    final userId = user?.uid; // Replace with the actual user ID
    final date = DateTime.now();

    if (text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .add({
          'text': text,
          'user_id': userId,
          'date': date,
          'time': Timestamp.fromDate(date),
          'profileImage': loggedInUser.profileImageReference
        });
        _commentController.clear();
      } catch (error) {
        print('Error adding comment: $error');
      }
    }
  }

  // Function to show the comment input bottom sheet
  void showCommentInputSheet(
    String postId,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(labelText: 'Add a Comment'),
                onSubmitted: (_) => addComment(postId, _commentController.text),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  addComment(postId, _commentController.text);
                },
                child: const Text('Add Comment'),
              ),
            ],
          ),
        );
      },
    );
  }

  void showAdminCommentInputSheet(
    String postId,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(labelText: 'Add a Comment'),
                onSubmitted: (_) =>
                    addAdminComment(postId, _commentController.text),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  addAdminComment(postId, _commentController.text);
                },
                child: const Text('Add Comment'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text("Social Shine"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              // const SizedBox(
              //   height: 50,
              // ),
              const Text(
                "FROM TEAM",
                style: TextStyle(fontSize: 18.0),
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('admin_post')
                    .orderBy("timestamp", descending: true)
                    .snapshots(),
                builder:
                    (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                  if (streamSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (streamSnapshot.connectionState ==
                      ConnectionState.active) {
                    final product = streamSnapshot.data?.docs;
                    if (product == null || product.isEmpty) {
                      return const Center(child: Text('No Post Found'));
                    } else {
                      return SingleChildScrollView(
                        child: Column(children: [
                          for (final data in product) ...[
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      data['profileImage'] != null
                                          ? Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius: BorderRadius
                                                      .all(Radius.circular(
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2))),
                                              child: CachedNetworkImage(
                                                imageUrl: data['profileImage'],
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    1,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    1,
                                              ),
                                            )
                                          : Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius: BorderRadius
                                                      .all(Radius.circular(
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2))),
                                            ),
                                      // if (FirebaseAuth.instance
                                      //         .currentUser!.email !=
                                      //     adminEmail) ...[
                                      // const Spacer(),
                                      // if (data['userId'] ==
                                      //     FirebaseAuth.instance
                                      //         .currentUser!.uid)
                                      // GestureDetector(
                                      //   child: const Icon(
                                      //     Icons.delete,
                                      //     color: Colors.red,
                                      //   ),
                                      //   onTap: () {
                                      //     deleteAdminPost(data.id);
                                      //   },
                                      // )
                                      // ],
                                      FutureBuilder(
                                        future: isUserAdmin(user!.uid),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<dynamic> snapshot) {
                                          if (snapshot.hasData) {
                                            if (snapshot.data) {
                                              return GestureDetector(
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onTap: () {
                                                  deleteAdminPost(data.id);
                                                },
                                              );
                                            } else {
                                              return const SizedBox();
                                            }
                                          }
                                          return const SizedBox();
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Text(data['description']),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  !(data.data() as Map)
                                              .containsKey('postImages') ||
                                          data['postImages'] == null
                                      ? const SizedBox()
                                      : VisibilityDetector(
                                          onVisibilityChanged:
                                              (visibilityInfo) {
                                            var visiblePercentage =
                                                visibilityInfo.visibleFraction *
                                                    100;
                                            if (visiblePercentage == 100) {
                                              var temp;
                                              try {
                                                temp = data["view"];
                                              } on Exception {}
                                              int view = temp ?? 0;
                                              view++;
                                              FirebaseFirestore.instance
                                                  .collection('admin_post')
                                                  .doc(data.id)
                                                  .update({'view': view});
                                            }
                                          },
                                          key: Key(data.id),
                                          child: StaggeredGrid.count(
                                            crossAxisCount:
                                                1, // Vertical spacing
                                            crossAxisSpacing:
                                                4.0, // Number of columns
                                            children: (data['postImages']
                                                    as List)
                                                .map((e) => e.toString())
                                                .map((e) => Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      // Adjust the margin as needed
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                8.0), // Rounded corners
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return InteractiveViewer(
                                                                  child: Dialog(
                                                                    child:
                                                                        Stack(
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.8,
                                                                          height:
                                                                              MediaQuery.of(context).size.height * 0.8,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            image:
                                                                                DecorationImage(
                                                                              image: NetworkImage(e),
                                                                              // Replace 'e' with your image URL
                                                                              fit: BoxFit.contain,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Positioned(
                                                                          top:
                                                                              10.0,
                                                                          // Adjust the top position as needed
                                                                          right:
                                                                              10.0,
                                                                          // Adjust the right position as needed
                                                                          child:
                                                                              IconButton(
                                                                            icon:
                                                                                const Icon(Icons.close),
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context); // Close the dialog
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child: Image.network(
                                                            e,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.4,
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                      ),
                                                    ))
                                                .toList(), // Horizontal spacing
                                          ),
                                        ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          GestureDetector(
                                              onTap: () async {
                                                await likePostForAdmin(
                                                    data.id,
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                    data["likes"]);
                                                /* setState(() {
                                                         if (color ==
                                                             0xFFFF0000) {
                                                           color = 0xFF808080;
                                                         } else {
                                                           color = 0xFFFF0000;
                                                         }
                                                       });*/
                                              },
                                              child: Icon(
                                                Icons.favorite,
                                                color: data['likes'].contains(
                                                        data["userId"])
                                                    ? Colors.red
                                                    : Colors.grey,
                                              )),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          GestureDetector(
                                            child: const Icon(
                                              Icons.message_outlined,
                                              color: Colors.grey,
                                            ),
                                            onTap: () {
                                              showAdminCommentInputSheet(
                                                  data.id);
                                            },
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Icon(
                                            Icons.stacked_bar_chart_rounded,
                                          ),
                                          Text(data['view'].toString())
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      GestureDetector(
                                          onTap: () async {
                                            await postDetailsToFirestore(
                                                data.id,
                                                data['userId'],
                                                data['postImages'][0],
                                                data['profileImage'] ?? "",
                                                data['description']);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const SavePostScreen(),
                                              ),
                                            );
                                          },
                                          child: const Icon(
                                              Icons.bookmark_border,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                  Text('${data['likes'].length} likes'),
                                  const SizedBox(
                                    height: 20,
                                  ),

                                  //this is the comment section
                                  // StreamBuilder(
                                  //   stream: FirebaseFirestore.instance
                                  //       .collection('admin_post')
                                  //       .doc(data.id)
                                  //       .collection('comments')
                                  //       .orderBy('time', descending: true)
                                  //       .snapshots(),
                                  //   builder: (ctx, commentSnapshot) {
                                  //     if (commentSnapshot
                                  //         .connectionState ==
                                  //         ConnectionState.waiting) {
                                  //       return const CircularProgressIndicator();
                                  //     }
                                  //     final comments =
                                  //         commentSnapshot.data?.docs;

                                  //     if (comments == null) {
                                  //       return const SizedBox();
                                  //     }

                                  //     return ListView.separated(
                                  //       physics:
                                  //       const NeverScrollableScrollPhysics(),
                                  //       padding: EdgeInsets.zero,
                                  //       itemCount: comments.length,
                                  //       itemBuilder: (ctx, index) {
                                  //         final comment = comments[index];
                                  //         return ListTile(
                                  //           leading: Container(
                                  //             width: 30,
                                  //             height: 30,
                                  //             decoration: BoxDecoration(
                                  //                 color: Colors.grey,
                                  //                 borderRadius: BorderRadius
                                  //                     .all(Radius.circular(
                                  //                     MediaQuery.of(
                                  //                         context)
                                  //                         .size
                                  //                         .width /
                                  //                         2))),
                                  //             child: CachedNetworkImage(
                                  //               imageUrl: comment[
                                  //               "profileImage"] ??
                                  //                   "",
                                  //               width:
                                  //               MediaQuery.of(context)
                                  //                   .size
                                  //                   .width *
                                  //                   1,
                                  //               height:
                                  //               MediaQuery.of(context)
                                  //                   .size
                                  //                   .height *
                                  //                   1,
                                  //             ),
                                  //           ),
                                  //           subtitle:
                                  //           Text(comment['text']),
                                  //           title: FutureBuilder(
                                  //             future: getUserName(
                                  //                 comment['user_id']),
                                  //             builder: (BuildContext
                                  //             context,
                                  //                 AsyncSnapshot<String>
                                  //                 snapshot) {
                                  //               if (snapshot.hasData) {
                                  //                 return Text(
                                  //                     snapshot.data!);
                                  //               } else if (snapshot
                                  //                   .hasError) {
                                  //                 return const Text(
                                  //                     'User');
                                  //               } else {
                                  //                 return const Text(
                                  //                     'Loading');
                                  //               }
                                  //             },
                                  //           ),
                                  //           trailing: Column(
                                  //             mainAxisSize:
                                  //             MainAxisSize.min,
                                  //             children: [
                                  //               Text(
                                  //                 DateFormat('dd-MMM')
                                  //                     .format(
                                  //                     comment['date']
                                  //                         .toDate()),
                                  //               ),
                                  //               if (FirebaseAuth
                                  //                   .instance
                                  //                   .currentUser!
                                  //                   .email !=
                                  //                   adminEmail) ...[
                                  //                 if (data['userId'] ==
                                  //                     FirebaseAuth
                                  //                         .instance
                                  //                         .currentUser!
                                  //                         .uid)
                                  //                   GestureDetector(
                                  //                     child: const Icon(
                                  //                       Icons.delete,
                                  //                       color: Colors.red,
                                  //                     ),
                                  //                     onTap: () {
                                  //                       deleteAdminComment(
                                  //                           data.id,
                                  //                           comment.id);
                                  //                     },
                                  //                   )
                                  //               ],
                                  //               FutureBuilder(
                                  //                 future: isUserAdmin(
                                  //                     user!.uid),
                                  //                 builder: (BuildContext
                                  //                 context,
                                  //                     AsyncSnapshot<
                                  //                         dynamic>
                                  //                     snapshot) {
                                  //                   if (snapshot
                                  //                       .hasData) {
                                  //                     if (snapshot.data) {
                                  //                       return GestureDetector(
                                  //                         child:
                                  //                         const Icon(
                                  //                           Icons.delete,
                                  //                           color: Colors
                                  //                               .red,
                                  //                         ),
                                  //                         onTap: () {
                                  //                           deleteAdminComment(
                                  //                               data.id,
                                  //                               comment
                                  //                                   .id);
                                  //                         },
                                  //                       );
                                  //                     } else {
                                  //                       return const SizedBox();
                                  //                     }
                                  //                   }
                                  //                   return const SizedBox();
                                  //                 },
                                  //               ),
                                  //             ],
                                  //           ),
                                  //         );
                                  //       },
                                  //       separatorBuilder: (ctx, index) {
                                  //         return const Divider();
                                  //       },
                                  //       shrinkWrap: true,
                                  //     );
                                  //   },
                                  // ),
                                  // Text(timeago.format(
                                  //     DateTime.parse(data["timestamp"]))),
                                ],
                              ),
                            ),
                            const Divider(),
                            const SizedBox(
                              height: 8,
                            ),
                          ],
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
              const Text(
                "USERS POST",
                style: TextStyle(fontSize: 18.0),
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .orderBy("timestamp", descending: true)
                    .snapshots(),
                builder:
                    (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                  if (streamSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (streamSnapshot.connectionState ==
                      ConnectionState.active) {
                    final product = streamSnapshot.data?.docs;
                    if (product == null || product.isEmpty) {
                      return const Center(child: Text('No Post Found'));
                    } else {
                      return SingleChildScrollView(
                        child: Column(children: [
                          for (final data in product) ...[
                            FutureBuilder<String>(
                                future: null,
                                builder: (_, imageSnapshot) {
                                  return SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            data['profileImage'] != null
                                                ? Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey,
                                                        borderRadius: BorderRadius
                                                            .all(Radius.circular(
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2))),
                                                    child: Image(
                                                      image: NetworkImage(
                                                          data['profileImage']),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              1,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              1,
                                                    ),
                                                  )
                                                : Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey,
                                                        borderRadius: BorderRadius
                                                            .all(Radius.circular(
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2))),
                                                  ),
                                            if (FirebaseAuth.instance
                                                    .currentUser!.email !=
                                                adminEmail) ...[
                                              const Spacer(),
                                              if (data['userId'] ==
                                                  FirebaseAuth.instance
                                                      .currentUser!.uid)
                                                GestureDetector(
                                                  child: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  onTap: () {
                                                    deletePost(data.id);
                                                  },
                                                )
                                            ],
                                            FutureBuilder(
                                              future: isUserAdmin(user!.uid),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<dynamic>
                                                      snapshot) {
                                                if (snapshot.hasData) {
                                                  if (snapshot.data) {
                                                    return GestureDetector(
                                                      child: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      onTap: () {
                                                        deletePost(data.id);
                                                      },
                                                    );
                                                  } else {
                                                    return const SizedBox();
                                                  }
                                                }
                                                return const SizedBox();
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        Text(data['description']),
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        !(data.data() as Map).containsKey(
                                                    'postImages') ||
                                                data['postImages'] == null
                                            ? const SizedBox()
                                            : VisibilityDetector(
                                                onVisibilityChanged:
                                                    (visibilityInfo) {
                                                  var visiblePercentage =
                                                      visibilityInfo
                                                              .visibleFraction *
                                                          100;
                                                  if (visiblePercentage ==
                                                      100) {
                                                    var temp;
                                                    try {
                                                      temp = data["view"];
                                                    } on Exception {}
                                                    int view = temp ?? 0;
                                                    view++;
                                                    FirebaseFirestore.instance
                                                        .collection('posts')
                                                        .doc(data.id)
                                                        .update({'view': view});
                                                  }
                                                },
                                                key: Key(data.id),
                                                child: StaggeredGrid.count(
                                                  crossAxisCount:
                                                      1, // Vertical spacing
                                                  crossAxisSpacing:
                                                      4.0, // Number of columns
                                                  children: (data['postImages']
                                                          as List)
                                                      .map((e) => e.toString())
                                                      .map((e) => Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(4.0),
                                                            // Adjust the margin as needed
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0), // Rounded corners
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      return InteractiveViewer(
                                                                        child:
                                                                            Dialog(
                                                                          child:
                                                                              Stack(
                                                                            children: [
                                                                              Container(
                                                                                width: MediaQuery.of(context).size.width * 0.8,
                                                                                height: MediaQuery.of(context).size.height * 0.8,
                                                                                decoration: BoxDecoration(
                                                                                  image: DecorationImage(
                                                                                    image: NetworkImage(e),
                                                                                    // Replace 'e' with your image URL
                                                                                    fit: BoxFit.contain,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Positioned(
                                                                                top: 10.0,
                                                                                // Adjust the top position as needed
                                                                                right: 10.0,
                                                                                // Adjust the right position as needed
                                                                                child: IconButton(
                                                                                  icon: const Icon(Icons.close),
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context); // Close the dialog
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                                child: Image
                                                                    .network(
                                                                  e,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.3,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              ),
                                                            ),
                                                          ))
                                                      .toList(), // Horizontal spacing
                                                ),
                                              ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                GestureDetector(
                                                    onTap: () async {
                                                      await likePostForUser(
                                                        data.id,
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid,
                                                        data["likes"],
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons.favorite,
                                                      color: data['likes']
                                                              .contains(
                                                                  user!.uid)
                                                          ? Colors.red
                                                          : Colors.grey,
                                                    )),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                GestureDetector(
                                                  child: const Icon(
                                                    Icons.message_outlined,
                                                    color: Colors.grey,
                                                  ),
                                                  onTap: () {
                                                    showCommentInputSheet(
                                                        data.id);
                                                  },
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                const Icon(
                                                  Icons
                                                      .stacked_bar_chart_rounded,
                                                ),
                                                Text(data['view'].toString())
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            GestureDetector(
                                                onTap: () async {
                                                  await postDetailsToFirestore(
                                                      data.id,
                                                      data['userId'],
                                                      data['postImages'][0],
                                                      data['profileImage'] ??
                                                          "",
                                                      data['description']);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const SavePostScreen(),
                                                    ),
                                                  );
                                                },
                                                child: const Icon(
                                                    Icons.bookmark_border,
                                                    color: Colors.grey))
                                          ],
                                        ),
                                        Text('${data['likes'].length} likes'),
                                        Text(timeago.format(
                                            DateTime.parse(data["timestamp"]))),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        StreamBuilder(
                                          stream: FirebaseFirestore.instance
                                              .collection('posts')
                                              .doc(data.id)
                                              .collection('comments')
                                              .orderBy('time', descending: true)
                                              .snapshots(),
                                          builder: (ctx, commentSnapshot) {
                                            if (commentSnapshot
                                                    .connectionState ==
                                                ConnectionState.waiting) {
                                              return const CircularProgressIndicator();
                                            }
                                            final comments =
                                                commentSnapshot.data?.docs;

                                            if (comments == null) {
                                              return const SizedBox();
                                            }

                                            return ListView.separated(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              padding: EdgeInsets.zero,
                                              itemCount: comments.length,
                                              itemBuilder: (ctx, index) {
                                                final comment = comments[index];
                                                return ListTile(
                                                  leading: Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey,
                                                        borderRadius: BorderRadius
                                                            .all(Radius.circular(
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2))),
                                                    child: Image(
                                                      image: NetworkImage(comment[
                                                              "profileImage"] ??
                                                          ""),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              1,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              1,
                                                    ),
                                                  ),
                                                  subtitle:
                                                      Text(comment['text']),
                                                  title: FutureBuilder(
                                                    future: getUserName(
                                                        comment['user_id']),
                                                    builder: (BuildContext
                                                            context,
                                                        AsyncSnapshot<String>
                                                            snapshot) {
                                                      if (snapshot.hasData) {
                                                        return Text(
                                                            snapshot.data!);
                                                      } else if (snapshot
                                                          .hasError) {
                                                        return const Text(
                                                            'User');
                                                      } else {
                                                        return const Text(
                                                            'Loading');
                                                      }
                                                    },
                                                  ),
                                                  trailing: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        DateFormat('dd-MMM')
                                                            .format(
                                                                comment['date']
                                                                    .toDate()),
                                                      ),
                                                      if (FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .email !=
                                                          adminEmail) ...[
                                                        if (data['userId'] ==
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid)
                                                          GestureDetector(
                                                            child: const Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                            ),
                                                            onTap: () {
                                                              deleteComment(
                                                                  data.id,
                                                                  comment.id);
                                                            },
                                                          )
                                                      ],
                                                      FutureBuilder(
                                                        future: isUserAdmin(
                                                            user!.uid),
                                                        builder: (BuildContext
                                                                context,
                                                            AsyncSnapshot<
                                                                    dynamic>
                                                                snapshot) {
                                                          if (snapshot
                                                              .hasData) {
                                                            if (snapshot.data) {
                                                              return GestureDetector(
                                                                child:
                                                                    const Icon(
                                                                  Icons.delete,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                                onTap: () {
                                                                  deleteComment(
                                                                      data.id,
                                                                      comment
                                                                          .id);
                                                                },
                                                              );
                                                            } else {
                                                              return const SizedBox();
                                                            }
                                                          }
                                                          return const SizedBox();
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              separatorBuilder: (ctx, index) {
                                                return const Divider();
                                              },
                                              shrinkWrap: true,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            const Divider(),
                            const SizedBox(
                              height: 8,
                            ),
                          ],
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
    } catch (error) {
      print('Error deleting post: $error');
    }
  }

  Future<void> deleteAdminPost(String postId) async {
    try {
      await FirebaseFirestore.instance
          .collection('admin_post')
          .doc(postId)
          .delete();
    } catch (error) {
      print('Error deleting post: $error');
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (error) {
      print('Error deleting comment: $error');
    }
  }

  Future<void> deleteAdminComment(String postId, String commentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('admin_post')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (error) {
      print('Error deleting comment: $error');
    }
  }

  // Function to get the user's name based on user_id
  Future<String> getUserName(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return userDoc.get('fullName');
      }
    } catch (error) {
      print('Error fetching user name: $error');
    }
    return 'Unknown User'; // Return a default value if user not found or there's an error
  }

  final _auth = FirebaseAuth.instance;

  Future<String> likePostForUser(String postId, String uid, List likes) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        firebaseFirestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        firebaseFirestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> likePostForAdmin(String postId, String uid, List likes) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        firebaseFirestore.collection('admin_post').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        firebaseFirestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> postDetailsToFirestore(String postId, String userId,
      String postImage, String userImage, String description) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    UserModel userModel = UserModel();
    userModel.description = description;
    userModel.postImage = postImage;
    userModel.profileImageReference = userImage;
    userModel.timestamp = DateTime.now();
    userModel.likes = [];
    userModel.uid = userId;
    userModel.postId = postId;

    await firebaseFirestore
        .collection("users")
        .doc(user?.uid)
        .collection('bookmark')
        .doc(postId)
        .set(userModel.toMapPost());
    Fluttertoast.showToast(msg: "Your Post has been saved successfully");
  }
}
