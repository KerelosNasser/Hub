import 'package:farahs_hub/main.dart';
import 'package:farahs_hub/mainScreen/controller.dart';
import 'package:farahs_hub/mainScreen/app-launching-service.dart';
import 'package:get/get.dart';

class HubBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FarahhubController());
    Get.lazyPut(() => AppLauncherService());
    Get.lazyPut(() => NavigationController());
  }
}
