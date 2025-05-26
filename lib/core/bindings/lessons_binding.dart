import 'package:farahs_hub/daily_lessons/lessons-cotroller.dart';
import 'package:get/get.dart';

class LessonsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LessonController());
  }
}