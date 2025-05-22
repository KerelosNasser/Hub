import 'package:hive/hive.dart';

part 'lessons_model.g.dart';

@HiveType(typeId: 0)
class LessonModel {
  @HiveField(0)
  String englishWord;

  @HiveField(1)
  String arabicTranslation;

  @HiveField(2)
  String phrase;

  @HiveField(3)
  String explanation;

  @HiveField(4)
  DateTime createdAt;

  LessonModel({
    required this.englishWord,
    required this.arabicTranslation,
    required this.phrase,
    required this.explanation,
    required this.createdAt,
  });
}