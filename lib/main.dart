import 'package:farahs_hub/core/bindings/app_binding.dart';
import 'package:farahs_hub/core/routes/app_pages.dart';
import 'package:farahs_hub/core/services/notification_service.dart';
import 'package:farahs_hub/core/services/home_widget_service.dart';
import 'package:farahs_hub/expense_tracker/views/expense_tracker_page.dart';
import 'package:farahs_hub/health/health_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:farahs_hub/widgets/NavBar_main.dart';
import 'daily_lessons/LessonPage.dart';
import 'mainScreen/FarahHub_screen.dart';
import 'mainScreen/controller.dart';
import 'notes/views/note_list_screen.dart'; // Using modular structure
import 'notes/views/note_edit_screen.dart'; // Using modular structure
import 'package:hive_flutter/hive_flutter.dart';
import 'daily_lessons/lessons_model.dart';
import 'package:farahs_hub/health/health_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    await _initializeServices();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    runApp(const MyApp());
  }

Future<void> _initializeServices() async {
  await GetStorage.init();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    // Assuming 0 is LessonModelAdapter typeId
    Hive.registerAdapter(LessonModelAdapter());
  }

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.init();
  Get.put(notificationService, permanent: true);
  
  // Schedule all app notifications (Bible reminder and daily summary)
  await notificationService.scheduleAllNotifications();

  // Initialize home widget service with error handling
  try {
    final homeWidgetService = HomeWidgetService();
    await homeWidgetService.init();
    Get.put(homeWidgetService, permanent: true);
  } catch (e) {
    debugPrint('Failed to initialize home widget service: $e');
    // Continue app initialization even if home widget fails
  }

  // Initialize awesome notifications and health notification service
  final healthNotificationService = HealthNotificationService();
  await healthNotificationService.init();
  Get.put(healthNotificationService, permanent: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      init: ThemeController(),
      builder: (themeController) {
        final box = GetStorage();
        final bool hasCompletedOnboarding =
            box.read('hasCompletedOnboarding') ?? false;

        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Farah's Hub",
          theme: ThemeData(
            primarySwatch: Colors.pink,
            fontFamily: 'Roboto',
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.pink.shade800,
          ),
          themeMode: themeController.themeMode,
          initialBinding: AppBinding(),
          getPages: AppPages.routes,
          initialRoute: hasCompletedOnboarding ? Routes.HUB : Routes.ONBOARDING,
          unknownRoute: GetPage(
            name: '/notfound',
            page: () => const NotFoundPage(),
          ),
          // Register route mapping for deep links from home widget
          onGenerateRoute: (settings) {
            if (settings.name?.startsWith('farahshub://notes/add') ?? false) {
              // Route to create a new note
              return GetPageRoute(
                page: () => NoteEditScreen(),
              );
            } else if (settings.name?.startsWith('farahshub://notes') ??
                false) {
              // Route to the notes list
              return GetPageRoute(
                page: () => NoteListScreen(),
              );
            }
            return null;
          },
        );
      },
    );
  }
}

class ThemeController extends GetxController {
  final GetStorage _storage = GetStorage();
  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() {
    final savedTheme = _storage.read('theme_mode') ?? 'system';
    switch (savedTheme) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
  }

  void changeTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    _storage.write('theme_mode', themeMode.name);
    update();
  }
}

class NavigationController extends GetxController {
  final RxInt _selectedIndex = 0.obs;
  final List<GlobalKey<NavigatorState>> navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  int get selectedIndex => _selectedIndex.value;
  void onTabSelected(int index) {
    if (index == _selectedIndex.value) {
      navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      _selectedIndex.value = index;
    }
  }

  bool onWillPop() {
    final NavigatorState? navigatorState =
        navigatorKeys[_selectedIndex.value].currentState;
    if (navigatorState?.canPop() == true) {
      navigatorState!.pop();
      return false;
    }
    return true;
  }
}

class FarahHub extends StatelessWidget {
  const FarahHub({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavigationController>(
      init: NavigationController(),
      builder: (navController) {
        return WillPopScope(
          onWillPop: () async => navController.onWillPop(),
          child: Scaffold(
            backgroundColor: Colors.pink.shade800,
            appBar: _buildAppBar(context),
            body: _buildBody(navController),
            bottomNavigationBar: _buildBottomNavBar(navController),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        "Farah's Hub",
        style: TextStyle(
          color: Color(0xffedf3ff),
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        GetBuilder<FarahhubController>(
          builder: (controller) => IconButton(
            icon: const Icon(
              Icons.replay_circle_filled_outlined,
              color: Color(0xffedf3ff),
            ),
            tooltip: 'Replay Onboarding',
            onPressed: controller.replayOnboarding,
          ),
        ),
      ],
      backgroundColor: Colors.pink.shade800,
      elevation: 0,
    );
  }

  Widget _buildBody(NavigationController navController) {
    return Obx(() => IndexedStack(
          index: navController.selectedIndex,
          children: [
            _buildTabNavigator(0, () => FarahhubScreen(), navController),
            _buildTabNavigator(1, () => NoteListScreen(), navController),
            _buildTabNavigator(2, () => LessonScreen(), navController),
            _buildTabNavigator(3, () => const HealthPage(), navController),
            _buildTabNavigator(4, () => ExpenseTrackerPage(), navController), // Replace FreeAIToolsPage
          ],
        ));
  }

  Widget _buildTabNavigator(int index, Widget Function() pageBuilder,
      NavigationController navController) {
    return Navigator(
      key: navController.navigatorKeys[index],
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => pageBuilder(),
        settings: settings,
      ),
    );
  }

  Widget _buildBottomNavBar(NavigationController navController) {
    return Obx(() => BottomNavyNavBar(
          currentIndex: navController.selectedIndex,
          onTap: navController.onTabSelected,
        ));
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'App failed to initialize',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Please restart the app'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('Close App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64),
            SizedBox(height: 16),
            Text('Page not found', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
