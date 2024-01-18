class UserModel {
  String? uid;
  String? email;
  String? password;
  String? role;
  String? fullName;
  String? description;
  String? profileImageReference;
  String? postId;
  String? postImage;
  List<String>? postImages;
  DateTime? timestamp;
  List<dynamic>? likes;

  UserModel({
    this.postId,
    this.role,
    this.profileImageReference,
    this.fullName,
    this.description,
    this.email,
    this.password,
    this.likes,
    this.uid,
    this.postImage,
    this.postImages,
    this.timestamp,
  });

  factory UserModel.fromMapUserRegistration(map) {
    return UserModel(
      email: map['email'] ?? 'email',
      password: map['password'],
      profileImageReference: map['profileImage'],
      fullName: map['fullName'],
      role: map['role'],
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMapUserRegistration() {
    return {
      'email': email,
      'password': password,
      'fullName': fullName,
      'profileImage': profileImageReference,
      'timestamp': timestamp!.toIso8601String(),
      'role': 'user'
    };
  }

  Map<String, dynamic> toMapPost() {
    return {
      'description': description,
      'postImage': postImage,
      'userId': uid,
      'profileImage': profileImageReference,
      'postImages': postImages,
      'timestamp': timestamp!.toIso8601String(),
      "likes": likes,
      'postId': postId,
      'view': 0
    };
  }

  Map<String, dynamic> toMapBookmark() {
    return {
      'description': description,
      'postImage': postImage,
      'userId': uid,
      'profileImage': profileImageReference,
      'timestamp': timestamp!.toIso8601String(),
      "likes": likes,
      'postId': postId
    };
  }
}
