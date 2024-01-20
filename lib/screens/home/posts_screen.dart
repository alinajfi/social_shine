import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lost_found/controllers/posts_controller.dart';
import 'package:lost_found/models/posts_model.dart';
import 'package:lost_found/screens/home/widgets/post_widget.dart';

import '../../models/comment_model.dart';

class PostsScreen extends GetView<PostsController> {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    return SafeArea(
      child: GetBuilder<PostsController>(
        init: PostsController(),
        builder: (controller) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Admin posts"),
                  const SizedBox(
                    height: 20,
                  ),
                  StreamBuilder(
                    stream: controller.getAdminPosts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator.adaptive();
                      } else {
                        var data = snapshot.data?.docs;
                        if (data != null) {
                          List<PostsModel> posts = [];
                          for (var e in data) {
                            posts.add(PostsModel.fromMap(e.data()));
                          }
                          return _adminPosts(height, width, posts);
                        }
                        return const Text("No Posts found");
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text("User posts"),
                  StreamBuilder(
                    stream: controller.getPosts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator.adaptive();
                      } else {
                        var data = snapshot.data?.docs;
                        if (data != null) {
                          List<PostsModel> posts = [];
                          for (var e in data) {
                            posts.add(PostsModel.fromMap(e.data()));
                          }
                          return _adminPosts(height, width, posts);
                        }
                        return const Text("No Posts found");
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _adminPosts(double height, double width, List<PostsModel> posts) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            SizedBox(
              height: height * 0.45,
              width: width,
              child: PostWidget(post: posts[index], controller: controller),
            ),
            StreamBuilder(
                stream: controller.getCommentsForPost(posts[index].postId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator.adaptive();
                  } else {
                    var data = snapshot.data!.docs;
                    List<CommentModel> comments = [];

                    for (var e in data) {
                      comments.add(CommentModel.fromMap(e.data()));
                    }

                    return ExpansionTile(
                      backgroundColor: Colors.transparent,
                      iconColor: Colors.transparent,
                      trailing: null,
                      title: const Text("View all comments"),
                      children: comments
                          .map((e) => commentsUi(
                              e.commentText,
                              e.replies,
                              width,
                              posts[index].postId!,
                              e.commentId,
                              context))
                          .toList(),
                    );
                  }
                }),
          ],
        );
      },
    );
  }

  // _userPosts() {
  //   return ListView.separated(
  //       physics: const NeverScrollableScrollPhysics(),
  //       shrinkWrap: true,
  //       itemBuilder: (context, index) => Container(
  //             height: 200,
  //             width: 400,
  //             color: Colors.green,
  //           ),
  //       separatorBuilder: (context, index) => Container(
  //             child: const Text("comments section"),
  //           ),
  //       itemCount: 20);
  // }

  Widget commentsUi(String mainComment, List<CommentReplies> replies,
      double width, String postId, String commentId, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  mainComment,
                  overflow: TextOverflow.clip,
                ),
              ),
              Flexible(
                  child: TextButton(
                      onPressed: () {
                        controller.showCommentReplySheet(
                            postId, context, commentId);
                      },
                      child: const Text("reply"))),
            ],
          ),
          replies.isEmpty
              ? const SizedBox()
              : ExpansionTile(
                  controlAffinity: ListTileControlAffinity.platform,
                  trailing: const Text("view all replies"),
                  title: Text(replies.first.text),
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 30),
                      width: width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 1; i < replies.length; i++)
                            Text(replies[i].text)
                        ],
                      ),
                    )
                  ],
                )
        ],
      ),
    );
  }
}
