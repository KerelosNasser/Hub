import 'dart:async';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';

class HealthNotificationService extends GetxService {
  static const int NOTIFICATION_ID = 101;
  static const String CHANNEL_KEY = 'health_stats_channel';
  static const String GROUP_KEY = 'health_stats_group';
  static const String STORAGE_KEY = 'health_notification_enabled';
  
  // Get storage for persistence
  final GetStorage _storage = GetStorage();
  
  final Health _health = Health();
  
  // Observable values
  final RxInt steps = 0.obs;
  final RxDouble calories = 0.0.obs;
  final RxBool isEnabled = false.obs;
  
  Timer? _updateTimer;
  final Duration _updateInterval = const Duration(minutes: 15);

  // Initialize the notification service with improved error handling
  Future<void> init() async {
    try {
      // Check if notification was previously enabled
      isEnabled.value = _storage.read(STORAGE_KEY) ?? false;
      
      // Initialize the Awesome Notifications package with proper icon
      final initResult = await AwesomeNotifications().initialize(
        'resource://drawable/ic_notification', // Use white monochrome notification icon for status bar
        [
          NotificationChannel(
            channelKey: CHANNEL_KEY,
            channelName: 'Health Stats Notifications',
            channelDescription: 'Shows your current health statistics',
            importance: NotificationImportance.Low,
            locked: true,
            onlyAlertOnce: true,
            defaultPrivacy: NotificationPrivacy.Public,
            defaultColor: Colors.pink.shade600,
            ledColor: Colors.pink.shade600,
            enableVibration: false,
          ),
        ],
        debug: false, // Disable debug mode in production
      );
      
      if (!initResult) {
        debugPrint('Failed to initialize awesome notifications');
        return;
      }

      // Request notification permissions with safer approach
      try {
        final isAllowed = await AwesomeNotifications().isNotificationAllowed();
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
      } catch (e) {
        debugPrint('Error requesting notification permissions: $e');
        // Continue even if we couldn't get permissions, we'll retry later
      }
      
      // Register notification action streams
      AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
      );
      
      // Start notification if it was previously enabled - do this after a delay
      // to prevent blocking app startup
      if (isEnabled.value) {
        // Delay health data fetch to avoid startup slowness
        Future.delayed(const Duration(seconds: 5), () {
          startNotification();
        });
      }
    } catch (e) {
      debugPrint('Error initializing health notification service: $e');
      // Mark as disabled in case of error to prevent further attempts
      isEnabled.value = false;
      await _storage.write(STORAGE_KEY, false);
    }
  }
  
  // Static method to handle notification actions
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Handle notification action if needed (e.g., open health screen)
    if (receivedAction.channelKey == CHANNEL_KEY) {
      Get.toNamed('/health');
    }
  }
  
  // Start showing the health notification
  Future<void> startNotification() async {
    // Fetch initial health data
    await _fetchHealthData();
    
    // Create initial notification
    await _showHealthNotification();
    
    // Set up timer to update notification periodically
    _updateTimer = Timer.periodic(_updateInterval, (_) async {
      await _fetchHealthData();
      await _showHealthNotification();
    });
    
    // Save state to storage
    isEnabled.value = true;
    await _storage.write(STORAGE_KEY, true);
  }
  
  // Stop showing the health notification
  Future<void> stopNotification() async {
    _updateTimer?.cancel();
    await AwesomeNotifications().cancel(NOTIFICATION_ID);
    isEnabled.value = false;
    await _storage.write(STORAGE_KEY, false);
  }
  
  // Toggle notification on/off
  Future<void> toggleNotification() async {
    if (isEnabled.value) {
      await stopNotification();
    } else {
      await startNotification();
    }
  }
  
  // Fetch health data from Health Connect or HealthKit with improved error handling
  Future<void> _fetchHealthData() async {
    try {
      // Get permissions first
      final types = [
        HealthDataType.STEPS,
        HealthDataType.ACTIVE_ENERGY_BURNED,
      ];
      
      // Request authorization with timeout protection
      bool? authorized = false;
      try {
        authorized = await _health.requestAuthorization(types)
          .timeout(const Duration(seconds: 10), onTimeout: () {
            debugPrint('Health authorization request timed out');
            return false;
          });
      } catch (e) {
        debugPrint('Error requesting health authorization: $e');
        return;
      }
      
      if (authorized != true) {
        // User denied permissions or there was an error
        debugPrint('Health data authorization not granted');
        return;
      }
      
      // Get today's date range
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      
      // Initialize data lists with safe defaults
      List<HealthDataPoint> stepsData = [];
      List<HealthDataPoint> caloriesData = [];
      
      // Fetch steps for today with timeout protection
      try {
        stepsData = await _health.getHealthDataFromTypes(
          startTime: midnight,
          endTime: now,
          types: [HealthDataType.STEPS],
        ).timeout(const Duration(seconds: 10), onTimeout: () {
          debugPrint('Fetching step data timed out');
          return [];
        });
      } catch (e) {
        debugPrint('Error fetching step data: $e');
        // Continue with empty data
      }
      
      // Fetch calories burned for today with timeout protection
      try {
        caloriesData = await _health.getHealthDataFromTypes(
          startTime: midnight,
          endTime: now,
          types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        ).timeout(const Duration(seconds: 10), onTimeout: () {
          debugPrint('Fetching calorie data timed out');
          return [];
        });
      } catch (e) {
        debugPrint('Error fetching calorie data: $e');
        // Continue with empty data
      }
      
      // Calculate total steps
      int totalSteps = 0;
      for (var dataPoint in stepsData) {
        if (dataPoint.value is NumericHealthValue) {
          final numValue = (dataPoint.value as NumericHealthValue).numericValue;
          totalSteps += numValue.toInt();
        }
      }
      
      // Calculate total calories
      double totalCalories = 0;
      for (var dataPoint in caloriesData) {
        if (dataPoint.value is NumericHealthValue) {
          final numValue = (dataPoint.value as NumericHealthValue).numericValue;
          totalCalories += numValue;
        }
      }
      
      // Update the observable values
      steps.value = totalSteps;
      calories.value = totalCalories;
      
      debugPrint('Health data updated: $totalSteps steps, $totalCalories calories');
    } catch (e) {
      debugPrint('Error in health data fetch process: $e');
      // Don't throw - just log the error and continue
    }
  }
  
  // Show health notification with current data
  Future<void> _showHealthNotification() async {
    final dateStr = DateFormat('EEEE, MMMM d').format(DateTime.now());
    
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: NOTIFICATION_ID,
        channelKey: CHANNEL_KEY,
        groupKey: GROUP_KEY,
        title: 'Health Stats for $dateStr',
        body: '${steps.value} steps | ${calories.value.toStringAsFixed(1)} calories burned',
        category: NotificationCategory.Status,
        notificationLayout: NotificationLayout.Default,
        autoDismissible: false,
        locked: true,
        summary: 'Health tracking active',
        showWhen: true,
        icon: 'resource://drawable/ic_notification', // Small monochrome icon for status bar only
        // Don't set largeIcon to avoid affecting the app icon
        displayOnForeground: true,
        displayOnBackground: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'VIEW_HEALTH',
          label: 'View Details',
          actionType: ActionType.Default,
        ),
      ],
    );
  }
  
  // Public method to fetch health data for testing
  Future<void> fetchHealthData() async {
    await _fetchHealthData();
  }
  
  // Public method to update notification with current data (for testing)
  Future<void> updateNotificationNow() async {
    if (isEnabled.value) {
      await _showHealthNotification();
    }
  }
  
  // Clean up resources
  void dispose() {
    _updateTimer?.cancel();
  }
}
