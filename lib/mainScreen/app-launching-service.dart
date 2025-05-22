import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

class AppLauncherService extends GetxService {
  Future<void> onButtonPressed(String androidPackage, String iosUrlScheme, {String? specificChat}) async {
    if (specificChat != null) {
      if (await canLaunch(specificChat)) {
        await launch(specificChat);
      } else {
        Get.snackbar(
          'Error',
          'Unable to open the link.',
          duration: const Duration(seconds: 2),
        );
      }
      return;
    }

    bool isInstalled = await LaunchApp.isAppInstalled(
      androidPackageName: androidPackage,
      iosUrlScheme: iosUrlScheme,
    );

    if (isInstalled) {
      await LaunchApp.openApp(
        androidPackageName: androidPackage,
        iosUrlScheme: iosUrlScheme,
      );
    } else {
      Get.snackbar(
        'Error',
        'The app is not installed.',
        duration: const Duration(seconds: 2),
      );
    }
  }
}