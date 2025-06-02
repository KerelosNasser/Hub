import 'dart:convert';

class Note {
  int? id;
  String title;
  String description;
  DateTime createdAt;
  DateTime updatedAt;
  List<String> imagePaths;
  String? drawingPath;
  String color;

  Note({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.imagePaths = const [],
    this.drawingPath,
    this.color = '#FFE91E63', // Default pink color
  });

  // Create a copy of the current note with given parameters
  Note copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? imagePaths,
    String? drawingPath,
    String? color,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imagePaths: imagePaths ?? this.imagePaths,
      drawingPath: drawingPath ?? this.drawingPath,
      color: color ?? this.color,
    );
  }

  // Convert Note to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'imagePaths': jsonEncode(imagePaths),
      'drawingPath': drawingPath,
      'color': color,
    };
  }

  // Create Note from Map from database
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      imagePaths: List<String>.from(jsonDecode(map['imagePaths'] ?? '[]')),
      drawingPath: map['drawingPath'],
      color: map['color'] ?? '#FFE91E63',
    );
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $title, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, imagePaths: $imagePaths, drawingPath: $drawingPath, color: $color)';
  }
}
