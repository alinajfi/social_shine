class PostsModel {
  final int? view;
  final String? postImage;
  final String? description;
  final String? profileImage;
  final String? postId;
  final String? userId;
  final List<String?> likes;
  final List<String?> postImages;
  final DateTime timestamp;

  PostsModel({
    required this.view,
    required this.postImage,
    required this.description,
    required this.profileImage,
    required this.postId,
    required this.userId,
    required this.likes,
    required this.postImages,
    required this.timestamp,
  });

  factory PostsModel.fromMap(Map<String, dynamic> json) {
    return PostsModel(
      view: json['view'],
      postImage: json['postImage'],
      description: json['description'],
      profileImage: json['profileImage'],
      postId: json['postId'],
      userId: json['userId'],
      likes: List<String?>.from(json['likes']?.map((e) => e as String?) ?? []),
      postImages: List<String?>.from(
          json['postImages']?.map((e) => e as String?) ?? []),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'view': view,
      'postImage': postImage,
      'description': description,
      'profileImage': profileImage,
      'postId': postId,
      'userId': userId,
      'likes': likes,
      'postImages': postImages,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
