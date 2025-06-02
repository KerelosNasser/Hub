import 'package:get/get.dart';
import 'health_controller.dart';
import 'health_notification_service.dart';

class HealthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HealthNotificationService());
    Get.lazyPut(() => HealthController());
  }
}