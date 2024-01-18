class AnnouncementModel {
  final String title;
  final String message;
  final DateTime timestamp;

  AnnouncementModel({
    required this.title,
    required this.message,
    required this.timestamp,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
