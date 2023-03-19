import 'dart:convert';

class TodoModel {
  final String title;
  final String? description;
  final String? imageUrl;
  final String id;
  final String dateTime;
  final bool isCompleted;
  TodoModel({
    required this.title,
    this.description,
    this.imageUrl,
    required this.id,
    required this.dateTime,
    required this.isCompleted,
  });

  TodoModel copyWith({
    String? title,
    String? description,
    String? imageUrl,
    String? id,
    String? dateTime,
    bool? isCompleted,
  }) {
    return TodoModel(
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'id': id,
      'dateTime': dateTime,
      'isCompleted': isCompleted,
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      title: map['title'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'],
      id: map['id'] ?? '',
      dateTime: map['dateTime'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory TodoModel.fromJson(String source) =>
      TodoModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TodoModel(title: $title, description: $description, imageUrl: $imageUrl, id: $id, dateTime: $dateTime, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TodoModel &&
        other.title == title &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.id == id &&
        other.dateTime == dateTime &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        description.hashCode ^
        imageUrl.hashCode ^
        id.hashCode ^
        dateTime.hashCode ^
        isCompleted.hashCode;
  }
}
