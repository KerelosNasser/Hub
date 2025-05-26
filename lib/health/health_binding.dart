import 'package:get/get.dart';
import 'health_controller.dart';

class HealthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HealthController());
  }
}