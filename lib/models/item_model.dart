class ItemModel {
  final String name;
  final String location;
  final String itemStatus;
  final List<String> favouritesList;
  final DateTime time;
  final String imageUrl; // Add the imageUrl property

  ItemModel({
    required this.name,
    required this.location,
    required this.itemStatus,
    required this.favouritesList,
    required this.time,
    required this.imageUrl, // Initialize imageUrl in the constructor
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      itemStatus: json['itemStatus'] ?? '',
      favouritesList: (json['favouritesList'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      time: DateTime.tryParse(json['time'] ?? '') ?? DateTime.now(),
      imageUrl: json['imageUrl'] ?? '', // Parse the imageUrl property from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'itemStatus': itemStatus,
      'favouritesList': favouritesList,
      'time': time.toIso8601String(),
      'imageUrl': imageUrl, // Include imageUrl in the JSON representation
    };
  }
}
