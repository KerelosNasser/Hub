class Note {
  int? id;
  String title;
  String description;
  String? imagePath;
  String? drawingPath;
  DateTime createdAt;
  DateTime updatedAt;

  Note({
    this.id,
    required this.title,
    required this.description,
    this.imagePath,
    this.drawingPath,
    required this.createdAt,
    required this.updatedAt,
  }) {
    // Consider if validation should be here or before saving
    // validate();
  }

  // Corrected toMap method as an instance method
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'drawingPath': drawingPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Corrected fromMap method as a factory constructor
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imagePath: map['imagePath'],
      drawingPath: map['drawingPath'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}
