import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lost_found/controllers/posts_controller.dart';
import 'package:lost_found/models/posts_model.dart';
import 'package:timeago/timeago.dart' as time_ago;

class PostWidget extends StatelessWidget {
  const PostWidget({super.key, required this.post, required this.controller});
  final PostsModel post;
  final PostsController controller;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: width,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey,
                child: CachedNetworkImage(
                  imageUrl: post.profileImage!,
                  fit: BoxFit.fill,
                ),
              ),
              const IconButton(onPressed: null, icon: Icon(Icons.delete)),
            ],
          ),
        ),
        Text(post.description ?? ""),
        _postImage(height, width, post.postImages.first!),
        SizedBox(
          width: width,
          child: Row(
            children: [
              const IconButton(onPressed: null, icon: Icon(Icons.favorite)),
              IconButton(
                  onPressed: () {
                    controller.showCommentInputSheet(post.postId!, context);
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
