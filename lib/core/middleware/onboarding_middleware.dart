import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:farahs_hub/core/routes/app_pages.dart';

class OnboardingMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final box = GetStorage();
    final bool hasCompletedOnboarding =
        box.read('hasCompletedOnboarding') ?? false;
    if (hasCompletedOnboarding && route == Routes.ONBOARDING) {
      return const RouteSettings(name: Routes.HUB);
    }
    return null;
  }
}
