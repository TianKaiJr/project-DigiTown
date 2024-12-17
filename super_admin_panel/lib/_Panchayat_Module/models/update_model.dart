class UpdateModel {
  final String id;
  final String title;
  final String details;
  final String imageUrl;

  UpdateModel({
    required this.id,
    required this.title,
    required this.details,
    required this.imageUrl,
  });

  factory UpdateModel.fromJson(String id, Map<String, dynamic> json) {
    return UpdateModel(
      id: id,
      title: json['title'] as String,
      details: json['details'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'details': details,
      'imageUrl': imageUrl,
    };
  }
}
