import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentText;
  final String userId;
  final DateTime date;
  final Timestamp time;
  final String profileImage;
  final List<CommentReplies> replies;
  final String commentId;

  CommentModel({
    required this.commentText,
    required this.userId,
    required this.date,
    required this.time,
    required this.profileImage,
    required this.replies,
    required this.commentId,
  });

  CommentModel.fromMap(Map<String, dynamic> map)
      : commentText = map['commentText'],
        userId = map['userId'],
        commentId = map["commentId"],
        date = DateTime.parse(map['date']),
        time = map['time'] as Timestamp,
        profileImage = map['profileImage'],
        replies = (map['replies'] as List<dynamic>?)
                ?.map((replyMap) => CommentReplies.fromMap(replyMap))
                .toList() ??
            [];

  Map<String, dynamic> toMap() {
    return {
      'commentText': commentText,
      'userId': userId,
      'date': date.toIso8601String(),
      'time': time,
      "commentId": commentId,
      'profileImage': profileImage,
      'replies': replies.map((reply) => reply.toMap()).toList(),
    };
  }

  CommentModel copyWith({
    String? commentText,
    String? userId,
    DateTime? date,
    Timestamp? time,
    String? profileImage,
    List<CommentReplies>? replies,
    String? commentId,
  }) {
    return CommentModel(
      commentText: commentText ?? this.commentText,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      time: time ?? this.time,
      profileImage: profileImage ?? this.profileImage,
      replies: replies ?? this.replies,
      commentId: commentId ?? this.commentId,
    );
  }

  @override
  String toString() {
    return 'CommentModel{commentText: $commentText, userId: $userId, date: $date, time: $time, profileImage: $profileImage, replies: $replies}';
  }
}

class CommentReplies {
  final String replierId;
  final String text;

  CommentReplies({
    required this.replierId,
    required this.text,
  });

  CommentReplies.fromMap(Map<String, dynamic> map)
      : replierId = map['replierId'],
        text = map['text'];

  Map<String, dynamic> toMap() {
    return {
      'replierId': replierId,
      'text': text,
    };
  }

  @override
  String toString() {
    return 'CommentReplies{replierId: $replierId, text: $text}';
  }
}
