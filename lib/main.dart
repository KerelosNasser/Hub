import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:farahs_hub/todo/TaskModels/task_model.dart';
import 'package:farahs_hub/todo/notification-controller.dart';
import 'package:farahs_hub/todo/task%20controller.dart';
import 'package:farahs_hub/todo/todoScreens/to-do-main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:farahs_hub/widgets/NavBar_main.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:url_launcher/url_launcher.dart';
import 'AI/FeatureScreens/FreeAIToolsPage.dart';
import 'bible-not.dart';
import 'daily_lessons/LessonPage.dart';
import 'daily_lessons/lessons-cotroller.dart';
import 'mainScreen/FarahHub_screen.dart';
import 'mainScreen/app-launching-service.dart';
import 'mainScreen/controller.dart';
import 'notes/NoteList-screen.dart';
import 'notes/controller.dart';
import 'onboarding/onBoarding.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox('tasks');

  final box = GetStorage();

  AwesomeNotifications().initialize(
      'resource://drawable/ic_notification',
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          importance: NotificationImportance.High,
          playSound: true,
          enableLights: true,
          locked: true,
          criticalAlerts: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'daily_lessons',
          channelName: 'Daily Lessons',
          channelDescription: 'Notifications for daily language lessons',
          importance: NotificationImportance.High,
          playSound: true,
          locked: true,
          criticalAlerts: true,
          enableLights: true,
          enableVibration: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
      debug: true);
  await AwesomeNotifications()
      .requestPermissionToSendNotifications(permissions: [
    NotificationPermission.Alert,
    NotificationPermission.Sound,
    NotificationPermission.Badge,
    NotificationPermission.Vibration,
    NotificationPermission.Light,
    NotificationPermission.CriticalAlert,
    NotificationPermission.FullScreenIntent
  ]);
  final notificationService = NotificationService();
  await notificationService.initNotification();
  await notificationService.scheduleDailyBibleReminder();
  await AwesomeNotifications().requestPermissionToSendNotifications();
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: onNotificationTap,
  );

  bool hasCompletedOnboarding = box.read('hasCompletedOnboarding') ?? false;

  runApp(MyApp(hasCompletedOnboarding: hasCompletedOnboarding));
}

Future<void> onNotificationTap(ReceivedAction receivedAction) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (receivedAction.channelKey == 'bible_reminder') {
    const String bibleAppUrl = 'youversion://';
    if (await canLaunchUrl(Uri.parse(bibleAppUrl))) {
      await launchUrl(
        Uri.parse(bibleAppUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      const String fallbackUrl = 'https://www.bible.com/';
      await launchUrl(Uri.parse(fallbackUrl));
    }
  } else if (Get.currentRoute != '/lessons') {
    Get.toNamed('/lessons');
  }
}

class MyApp extends StatelessWidget {
  final bool hasCompletedOnboarding;

  const MyApp({
    required this.hasCompletedOnboarding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ar', ''), // Arabic
      ],
      debugShowCheckedModeBanner: false,
      title: "Farah's Hub",
      initialBinding: BindingsBuilder(() {
        Get.put(NotificationController());
        Get.put(TaskController());
        Get.put(LessonController());
        Get.put(FarahhubController());
        Get.put(AppLauncherService());
        Get.put(NoteController());
      }),
      initialRoute: hasCompletedOnboarding ? '/hub' : '/onboarding',
      getPages: [
        GetPage(name: '/onboarding', page: () => const OnBoardingPage()),
        GetPage(name: '/hub', page: () => const FarahHub()),
        GetPage(name: '/chatgpt', page: () => FreeAIToolsPage()),
        GetPage(name: '/lessons', page: () => LessonScreen()),
        GetPage(name: '/notes', page: () => NoteListScreen()),
        GetPage(name: '/todo', page: () => ToDoPage()),
      ],
    );
  }
}

class NavigationController extends GetxController {
  var selectedIndex = 0.obs;

  void onTabSelected(int index) {
    selectedIndex.value = index;
  }
}

class FarahHub extends StatelessWidget {
  const FarahHub({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navController = Get.put(NavigationController());

    return Scaffold(
      backgroundColor: Colors.pink.shade800,
      appBar: AppBar(
          title: const Text(
            "Farah's Hub",
            style: TextStyle(
                color: Color(0xffedf3ff),
                fontSize: 24,
                fontWeight: FontWeight.w700),
          ),
          backgroundColor: Colors.pink.shade800),
      body: Obx(() {
        return IndexedStack(
          index: navController.selectedIndex.value,
          children: [
            FarahhubScreen(),
            NoteListScreen(),
            ToDoPage(),
            LessonScreen(),
            FreeAIToolsPage(),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        return BottomNavyNavBar(
          currentIndex: navController.selectedIndex.value,
          onTap: navController.onTabSelected,
        );
      }),
    );
  }
}
