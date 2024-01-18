import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lost_found/controllers/posts_controller.dart';

class PostsScreen extends GetView<PostsController> {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  _adminPosts(),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text("User posts"),
                  _userPosts(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _adminPosts() {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) => Container(
              height: 200,
              width: 400,
              color: Colors.red,
            ),
        separatorBuilder: (context, index) => const ExpansionTile(
              title: Text("recent comment"),
              children: [
                Text("reply one "),
                Text("reply one "),
                Text("reply one "),
                Text("reply one "),
                Text("reply one "),
                Text("reply one "),
                Text("reply one "),
              ],
            ),
        itemCount: 20);
  }

  _userPosts() {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) => Container(
              height: 200,
              width: 400,
              color: Colors.green,
            ),
        separatorBuilder: (context, index) => Container(
              child: const Text("comments section"),
            ),
        itemCount: 20);
  }
}
