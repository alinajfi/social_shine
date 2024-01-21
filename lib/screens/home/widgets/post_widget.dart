// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timeago/timeago.dart' as time_ago;

import 'package:lost_found/controllers/posts_controller.dart';
import 'package:lost_found/models/posts_model.dart';

class PostWidget extends StatelessWidget {
  const PostWidget({
    Key? key,
    required this.post,
    required this.controller,
    required this.isAdmin,
  }) : super(key: key);
  final PostsModel post;
  final PostsController controller;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  height: height * 0.05,
                  width: height * 0.05,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: CachedNetworkImage(
                    imageUrl: post.profileImage!,
                    fit: BoxFit.fill,
                  ),
                ),
                IconButton(
                    onPressed: () {
                      if (post.userId ==
                          FirebaseAuth.instance.currentUser!.uid) {
                        if (isAdmin) {
                          controller.deleteAdminPost(post.postId!);
                        } else {
                          controller.deletePost(post.postId!);
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg: "Not authorized",
                            gravity: ToastGravity.CENTER);
                      }
                    },
                    icon: const Icon(Icons.delete)),
              ],
            ),
          ),
          Text(post.description ?? ""),
          _postImage(height, width, post.postImages.first!),
          SizedBox(
            width: width,
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      isAdmin
                          ? controller.likePostForAdmin(
                              post.postId!, post.userId!, post.likes)
                          : controller.likePostForUser(
                              post.postId!, post.userId!, post.likes);
                    },
                    icon: post.likes.contains(post.userId)
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : const Icon(Icons.favorite)),
                IconButton(
                    onPressed: () {
                      controller.showCommentInputSheet(
                          post.postId!, context, isAdmin);
                    },
                    icon: const Icon(Icons.comment)),
                const Spacer(),
                const Icon(Icons.view_sidebar_sharp),
                const Text("20"),
                const IconButton(onPressed: null, icon: Icon(Icons.bookmark)),
              ],
            ),
          ),
          Text(time_ago.format(DateTime.parse(post.timestamp.toString())))
        ],
      ),
    );
  }

  _postImage(double height, double width, String imageUrl) {
    return SizedBox(
      height: height * 0.25,
      width: width,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.fill,
      ),
    );
  }
}
