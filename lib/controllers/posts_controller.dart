import "dart:developer";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:get/get.dart";
import "package:lost_found/models/comment_model.dart";
import "package:lost_found/models/user_model.dart";
import "package:lost_found/utils/firebase_constants.dart";
import "package:uuid/uuid.dart";

class PostsController extends GetxController {
  Future<void> deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
    } catch (error) {
      log('Error deleting post: $error');
    }
  }

  Future<void> deleteAdminPost(String postId) async {
    try {
      await FirebaseFirestore.instance
          .collection('admin_post')
          .doc(postId)
          .delete();
    } catch (error) {
      log('Error deleting post: $error');
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
      log('Error deleting comment: $error');
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
      log('Error deleting comment: $error');
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
      log('Error fetching user name: $error');
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

  // getComments
  Stream<QuerySnapshot<Map<String, dynamic>>> getCommentsForPost(
      String postId) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection(FirebaseConstants.commmentsCollection)
        .orderBy('time', descending: true)
        .snapshots();
  }

  //get Posts of the user
  Stream<QuerySnapshot<Map<String, dynamic>>> getPosts() {
    return FirebaseFirestore.instance
        .collection(FirebaseConstants.postsCollection)
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAdminPosts() {
    return FirebaseFirestore.instance
        .collection(FirebaseConstants.adminPostsCollection)
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  @override
  void onInit() {
    super.onInit();
    // getPosts();
    commentController = TextEditingController();
    commentReplyController = TextEditingController();
    getLoggedInUser();
  }

  getAdminComments(String postId) {
    FirebaseFirestore.instance
        .collection('admin_post')
        .doc(postId)
        .collection('comments')
        .orderBy('time', descending: true)
        .snapshots();
  }

  // Function to add a comment to the post
  Future<void> addComment(String postId, String comment) async {
    final text = commentController.text.trim();
    final userId = FirebaseAuth
        .instance.currentUser!.uid; // Replace with the actual user ID
    final date = DateTime.now();

    if (text.isNotEmpty) {
      try {
        CommentModel comment = CommentModel(
            commentId: const Uuid().v1(),
            commentText: text,
            userId: userId,
            date: date,
            time: Timestamp.fromDate(date),
            profileImage: loggedInUser.profileImageReference!,
            replies: []);
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(comment.commentId)
            .set(comment.toMap());
        commentController.clear();
      } catch (error) {
        log('Error adding comment: $error');
      }
    }
  }

  Future<void> replyToAComment(String postID, String commentId) async {
    final text = commentController.text.trim();
    final userId = FirebaseAuth.instance.currentUser!.uid;

    if (text.isNotEmpty) {
      try {
        var fetechedData = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postID)
            .collection('comments')
            .doc(commentId)
            .get();

        log(fetechedData.data().toString());

        var fetchedComment =
            CommentModel.fromMap(fetechedData.data() as Map<String, dynamic>);

        var commentsList = fetchedComment.replies;
        commentsList.add(CommentReplies(replierId: userId, text: text));

        fetchedComment.copyWith(replies: commentsList);
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postID)
            .collection('comments')
            .doc(commentId)
            .update(fetchedComment.toMap());
      } catch (error) {
        log('Error adding comment: $error');
      }
    }
  }

  getLoggedInUser() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMapUserRegistration(value.data());
    });
  }

  void showCommentInputSheet(String postId, BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: commentController,
                decoration: const InputDecoration(labelText: 'Add a Comment'),
                onSubmitted: (_) => addComment(postId, commentController.text),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  addComment(postId, commentController.text);
                },
                child: const Text('Add Comment'),
              ),
            ],
          ),
        );
      },
    );
  }

  void showCommentReplySheet(
      String postId, BuildContext context, String commentId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: commentController,
                decoration: const InputDecoration(labelText: 'Add a reply'),
                onSubmitted: (_) => replyToAComment(postId, commentId),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  replyToAComment(postId, commentId);
                  commentController.clear();
                },
                child: const Text('Add Comment'),
              ),
            ],
          ),
        );
      },
    );
  }

  UserModel loggedInUser = UserModel();

  late TextEditingController commentController;
  late TextEditingController commentReplyController;
}

// var dummmyComments = [
//   CommentModel(
//       commentId: "",
//       commentText: "bala bala",
//       userId: "no idea",
//       date: DateTime.now(),
//       time: Timestamp.fromDate(DateTime.now()),
//       profileImage: "",
//       replies: <CommentReplies>[
//         CommentReplies(replierId: "repier1", text: "right"),
//         CommentReplies(replierId: "repier1", text: "left"),
//         CommentReplies(replierId: "repier1", text: "center"),
//         CommentReplies(replierId: "repier1", text: "up"),
//         CommentReplies(replierId: "repier1", text: "down"),
//       ]),
//   CommentModel(
//       commentId: "",
//       commentText: "bala bala",
//       userId: "no idea",
//       date: DateTime.now(),
//       time: Timestamp.fromDate(DateTime.now()),
//       profileImage: "",
//       replies: <CommentReplies>[
//         CommentReplies(replierId: "repier1", text: "right"),
//       ]),
//   CommentModel(
//       commentId: "",
//       commentText: "bala bala",
//       userId: "no idea",
//       date: DateTime.now(),
//       time: Timestamp.fromDate(DateTime.now()),
//       profileImage: "",
//       replies: <CommentReplies>[
//         CommentReplies(replierId: "repier1", text: "right"),
//       ]),
//   CommentModel(
//       commentId: "",
//       commentText: "bala bala",
//       userId: "no idea",
//       date: DateTime.now(),
//       time: Timestamp.fromDate(DateTime.now()),
//       profileImage: "",
//       replies: <CommentReplies>[
//         CommentReplies(replierId: "repier1", text: "right"),
//       ]),
//   CommentModel(
//       commentId: "",
//       commentText: "bala bala",
//       userId: "no idea",
//       date: DateTime.now(),
//       time: Timestamp.fromDate(DateTime.now()),
//       profileImage: "",
//       replies: <CommentReplies>[
//         CommentReplies(replierId: "repier1", text: "right"),
//       ]),
//   CommentModel(
//       commentId: "",
//       commentText: "bala bala",
//       userId: "no idea",
//       date: DateTime.now(),
//       time: Timestamp.fromDate(DateTime.now()),
//       profileImage: "",
//       replies: <CommentReplies>[
//         CommentReplies(replierId: "repier1", text: "right"),
//       ]),
//   CommentModel(
//       commentId: "",
//       commentText: "bala bala",
//       userId: "no idea",
//       date: DateTime.now(),
//       time: Timestamp.fromDate(DateTime.now()),
//       profileImage: "",
//       replies: <CommentReplies>[
//         CommentReplies(replierId: "repier1", text: "right"),
//       ]),
// ];

