import 'package:farahs_hub/daily_lessons/lessons-cotroller.dart';
import 'package:farahs_hub/main.dart';
import 'package:farahs_hub/mainScreen/controller.dart';
import 'package:farahs_hub/notes/controllers/note_controller.dart';
import 'package:farahs_hub/notes/services/hybird_database_service.dart';
import 'package:get/get.dart';
import 'package:farahs_hub/health/health_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    try {
      Get.put(HybridDatabaseService.instance, permanent: true);

      Get.put(FarahhubController());
      Get.put(NoteController());
      Get.put(LessonController());
      Get.put(NavigationController());

      try {
        Get.put(HealthController());
      } catch (e) {
        // Continue without health controller if it fails
      }
    } catch (e) {
      throw Exception('Failed to initialize app bindings: $e');
    }
  }
}
