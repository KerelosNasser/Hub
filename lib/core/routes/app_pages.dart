import 'package:farahs_hub/core/bindings/hub_binding.dart';
import 'package:farahs_hub/core/bindings/lessons_binding.dart';
import 'package:farahs_hub/core/bindings/notes_binding.dart';
import 'package:farahs_hub/core/middleware/onboarding_middleware.dart';
import 'package:farahs_hub/daily_lessons/LessonPage.dart';
import 'package:farahs_hub/health/health_binding.dart';
import 'package:farahs_hub/health/health_page.dart';
import 'package:farahs_hub/main.dart';
import 'package:farahs_hub/notes/views/note_edit_screen.dart';
import 'package:farahs_hub/notes/views/note_list_screen.dart';
import 'package:farahs_hub/onboarding/onBoarding.dart';
import 'package:farahs_hub/tests/health_notification_test.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

class Routes {
  static const ONBOARDING = '/onboarding';
  static const HUB = '/hub';
  static const NOTES = '/notes';
  static const NOTES_ADD = '/notes/add';
  static const LESSONS = '/lessons';
  static const AI_TOOLS = '/ai-tools';
  static const HEALTH = '/health';

  static const HEALTH_NOTIFICATION_TEST = '/health-notification-test';
}

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnBoardingPage(),
      middlewares: [OnboardingMiddleware()],
    ),
    GetPage(
      name: Routes.HUB,
      page: () => FarahHub(),
      binding: HubBinding(),
    ),
    GetPage(
      name: Routes.NOTES,
      page: () => NoteListScreen(),
      binding: NotesBinding(), // Using our new binding class
    ),
    GetPage(
      name: Routes.NOTES_ADD,
      page: () => NoteEditScreen(),
      binding: NotesBinding(), // Using our new binding class
    ),
    GetPage(
      name: Routes.LESSONS,
      page: () => LessonScreen(),
      binding: LessonsBinding(),
    ),
    GetPage(
      name: Routes.HEALTH,
      page: () => const HealthPage(),
      binding: HealthBinding(),
    ),
    GetPage(
      name: Routes.HEALTH_NOTIFICATION_TEST,
      page: () => const HealthNotificationTestScreen(),
      binding: HealthBinding(),
    ),
  ];
}
