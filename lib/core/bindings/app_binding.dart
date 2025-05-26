import 'package:farahs_hub/core/services/database_service.dart';
import 'package:farahs_hub/core/services/notification_service.dart';
import 'package:farahs_hub/daily_lessons/lessons-cotroller.dart';
import 'package:farahs_hub/main.dart';
import 'package:farahs_hub/mainScreen/controller.dart';
import 'package:farahs_hub/notes/controller.dart';
import 'package:get/get.dart';
import 'package:farahs_hub/health/health_controller.dart';
import 'package:flutter/foundation.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    try {
      // Core Services - Initialize with error handling
      Get.put(NotificationService(), permanent: true);
      debugPrint('✓ NotificationService initialized');

      Get.put(DatabaseService(), permanent: true);
      debugPrint('✓ DatabaseService initialized');

      // Controllers
      Get.put(FarahhubController());
      Get.put(NoteController());
      Get.put(LessonController());
      Get.put(NavigationController());

      // Health Controller - Initialize separately to handle health-specific errors
      try {
        Get.put(HealthController());
        debugPrint('✓ HealthController initialized');
      } catch (e) {
        debugPrint('⚠ HealthController initialization failed: $e');
        // Continue without health controller if it fails
      }

      debugPrint('✓ App bindings completed successfully');
    } catch (e) {
      debugPrint('✗ App binding failed: $e');
      // Re-throw to prevent app from starting with incomplete bindings
      throw Exception('Failed to initialize app bindings: $e');
    }
  }
}
