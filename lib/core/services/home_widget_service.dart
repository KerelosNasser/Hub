import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';
import 'package:intl/intl.dart';

/// Background callback function that will be executed by Workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'updateWidgetBackground':
        try {
          // Initialize home widget with app group
          await HomeWidget.setAppGroupId('group.com.farahshub');

          // Update widget with current date
          final now = DateTime.now();
          final formattedDate = DateFormat('MMMM d, yyyy').format(now);
          await HomeWidget.saveWidgetData('date_key', formattedDate);

          // Update other widget data
          await HomeWidget.saveWidgetData('title_key', "Farah's Hub");
          await HomeWidget.saveWidgetData('message_key', "Tap to access notes");

          // Request widget update
          await HomeWidget.updateWidget(
            iOSName: 'FarahsHubWidget',
            androidName: 'FarahsHubWidgetProvider',
          );
          return true;
        } catch (e) {
          return false;
        }
      default:
        return false;
    }
  });
}

/// Class to manage home widget functionality
class HomeWidgetService extends GetxService {
  static const String appGroupId = 'group.com.farahshub';
  static const String iOSWidgetName = 'FarahsHubWidget';
  static const String androidWidgetName = 'FarahsHubWidgetProvider';

  // Keys for data shared with the widget
  static const String dateKey = 'date_key';
  static const String messageKey = 'message_key';
  static const String titleKey = 'title_key';
  static const String backgroundTask = 'updateWidgetBackground';

  /// Initialize the service
  Future<HomeWidgetService> init() async {
    debugPrint('Initializing HomeWidgetService');

    try {
      // Initialize the home widget plugin
      await HomeWidget.setAppGroupId(appGroupId);

      // Workmanager initialization disabled due to compatibility issues
      // Will use direct widget updates instead
      debugPrint('Skipping Workmanager initialization - using direct updates');

      // Setup initial data for the widget
      await updateWidgetData();

      // Set up URI scheme listener for handling widget clicks
      await _setupWidgetClickListeners();
    } catch (e) {
      debugPrint('Error initializing HomeWidgetService: $e');
    }

    return this;
  }

  /// Update the widget with latest data
  Future<void> updateWidget({
    required String title,
    required String message,
    String? date,
  }) async {
    try {
      // Save data that the widget will use
      await HomeWidget.saveWidgetData(titleKey, title);
      await HomeWidget.saveWidgetData(messageKey, message);

      if (date != null) {
        await HomeWidget.saveWidgetData(dateKey, date);
      } else {
        // Default to current date in format "June 2, 2025"
        final now = DateTime.now();
        final formattedDate = DateFormat('MMMM d, yyyy').format(now);
        await HomeWidget.saveWidgetData(dateKey, formattedDate);
      }

      // Request update for all widgets
      await HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );
    } catch (e) {
      debugPrint('Error updating widget: $e');
    }
  }

  // Handle widget clicks through URI scheme
  Future<void> _setupWidgetClickListeners() async {
    // Listen for widget URI launches
    HomeWidget.widgetClicked.listen((uri) {
      _handleWidgetClicked(uri.toString());
    });

    // Check if the app was launched by a widget
    final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (initialUri != null) {
      _handleWidgetClicked(initialUri.toString());
    }
  }

  // Handle different widget click actions
  void _handleWidgetClicked(String uri) {
    if (uri.contains('farahshub://notes/add')) {
      // Navigate to add note screen
      Get.toNamed('/notes/add');
    } else if (uri.contains('farahshub://notes')) {
      // Navigate to notes list screen
      Get.toNamed('/notes');
    }
  }

  // Update the widget with custom data
  Future<void> updateWidgetData() async {
    try {
      // Set title
      await HomeWidget.saveWidgetData<String>('title_key', "Farah's Hub");

      // Set current date
      final now = DateTime.now();
      final formattedDate = DateFormat('MMMM d, yyyy').format(now);
      await HomeWidget.saveWidgetData<String>('date_key', formattedDate);

      // Set a message
      await HomeWidget.saveWidgetData<String>(
          'message_key', 'Tap to access notes');

      // Request an update for the widget
      await HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );
    } catch (e) {
      debugPrint('Error updating widget: $e');
    }
  }

  // Public getMonthName method is used instead of the private one

  // Already defined a proper implementation above
  // Helper method to get month name from month number
  String getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }
}

// This second callbackDispatcher function is removed as it's a duplicate
// of the one at the top of the file. The top-level function is the one
// that Workmanager will call, and having duplicates causes errors.
