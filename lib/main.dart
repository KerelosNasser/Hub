import 'package:farahs_hub/core/bindings/app_binding.dart';
import 'package:farahs_hub/core/routes/app_pages.dart';
import 'package:farahs_hub/core/translations/app_translations.dart';
import 'package:farahs_hub/health/health_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:farahs_hub/widgets/NavBar_main.dart';
import 'AI/FeatureScreens/FreeAIToolsPage.dart';
import 'daily_lessons/LessonPage.dart';
import 'mainScreen/FarahHub_screen.dart';
import 'mainScreen/controller.dart';
import 'notes/NoteList-screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'daily_lessons/lessons_model.dart';

void main() async {
  // Ensure proper initialization
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize services with proper error handling
    await _initializeServices();

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp(const MyApp());
  } catch (e, stackTrace) {
    // Log error and show fallback UI
    debugPrint('App initialization failed: $e');
    debugPrint('Stack trace: $stackTrace');
    runApp(const ErrorApp());
  }
}

Future<void> _initializeServices() async {
  try {
    // Initialize GetStorage with error handling
    await GetStorage.init();
    debugPrint('✓ GetStorage initialized successfully');
  } catch (e) {
    debugPrint('✗ GetStorage initialization failed: $e');
    throw Exception('Failed to initialize GetStorage: $e');
  }

  try {
    // Initialize Hive with error handling
    await Hive.initFlutter();
    debugPrint('✓ Hive initialized successfully');

    // Register adapters with validation
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(LessonModelAdapter());
      debugPrint('✓ LessonModelAdapter registered');
    }
    // Add other adapters as needed
  } catch (e) {
    debugPrint('✗ Hive initialization failed: $e');
    throw Exception('Failed to initialize Hive: $e');
  }

  debugPrint('✓ All services initialized successfully');
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

          // Theme configuration
          theme: ThemeData(
            primarySwatch: Colors.pink,
            fontFamily: 'Roboto',
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.pink.shade800,
          ),
          themeMode: themeController.themeMode,

          // Bindings and translations
          initialBinding: AppBinding(),
          translations: AppTranslations(),
          locale: _getLocale(),
          fallbackLocale: const Locale('en', 'US'),

          // Localization
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ar', 'SA'),
          ],

          // Navigation
          getPages: AppPages.routes,
          initialRoute: hasCompletedOnboarding ? Routes.HUB : Routes.ONBOARDING,

          // Error handling
          unknownRoute: GetPage(
            name: '/notfound',
            page: () => const NotFoundPage(),
          ),
        );
      },
    );
  }

  Locale _getLocale() {
    final box = GetStorage();
    final savedLocale = box.read('app_locale');

    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      return Locale(parts[0], parts.length > 1 ? parts[1] : '');
    }

    return Get.deviceLocale ?? const Locale('en', 'US');
  }
}

// Theme Controller for better theme management
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

// Enhanced Navigation Controller with better state management
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
      // Pop to first route if tapping the same tab
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

// Enhanced FarahHub with better error handling and performance
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
            _buildTabNavigator(4, () => FreeAIToolsPage(), navController),
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

// Error fallback app
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

// 404 Page
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
