import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  Future<NotificationService> init() async {
    try {
      await AwesomeNotifications().initialize(
          'resource://drawable/ic_notification',
          [
            NotificationChannel(
              channelKey: 'bible_reminder',
              channelName: 'Bible Reading Reminders',
              channelDescription: 'Daily reminders to read the Bible.',
              importance: NotificationImportance.High,
              defaultRingtoneType: DefaultRingtoneType.Notification,
              locked: true,
              criticalAlerts: true,
              playSound: true,
              enableVibration: true,
            ),
            NotificationChannel(
              channelKey: 'daily_lessons',
              channelName: 'Daily Lesson Reminders',
              channelDescription: 'Reminders for new daily lessons.',
              importance: NotificationImportance.Default,
              defaultRingtoneType: DefaultRingtoneType.Notification,
              playSound: true,
              enableVibration: true,
            ),
            NotificationChannel(
              channelKey: 'health_updates',
              channelName: 'Health Stat Updates',
              channelDescription: 'Updates about your health statistics.',
              importance: NotificationImportance.Default,
              defaultRingtoneType: DefaultRingtoneType.Notification,
              locked: false,
              playSound: false,
              enableVibration: false,
              onlyAlertOnce: true,
            ),
            NotificationChannel(
              channelKey: 'daily_summary',
              channelName: 'Daily Summary Reminder',
              channelDescription: 'Reminder to add your daily summary note.',
              importance: NotificationImportance.High,
              defaultRingtoneType: DefaultRingtoneType.Notification,
              playSound: true,
              enableVibration: true,
              ledColor: Colors.blue,
            )
          ],
          debug: false);

      bool isAllowedToSendNotifications =
          await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowedToSendNotifications) {
        await AwesomeNotifications()
            .requestPermissionToSendNotifications(permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.Light,
          NotificationPermission.CriticalAlert,
          NotificationPermission.FullScreenIntent,
        ]);
      }
      return this;
    } catch (_) {
      // Silent fail in production
      return this;
    }
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required String channelKey,
    required int id,
    required NotificationCalendar schedule,
    Map<String, String>? payload,
    String? summary,
    NotificationLayout notificationLayout = NotificationLayout.Default,
    String? bigPicture,
    String? largeIcon,
    List<NotificationActionButton>? actionButtons,
  }) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: channelKey,
          title: title,
          body: body,
          payload: payload,
          summary: summary,
          notificationLayout: notificationLayout,
          bigPicture: bigPicture,
          largeIcon: largeIcon,
          wakeUpScreen: true,
          autoDismissible: true,
        ),
        schedule: schedule,
        actionButtons: actionButtons,
      );
    } catch (_) {
      // Silent fail in production
    }
  }

  Future<void> scheduleDailyBibleReminder() async {
    const int bibleReminderId = 100;
    const String bibleChannelKey = 'bible_reminder';

    try {
      // Cancel any existing notifications first
      await AwesomeNotifications()
          .cancelNotificationsByChannelKey(bibleChannelKey);

      // Fixed Bible reminder - using createNotification directly for better reliability
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: bibleReminderId,
          channelKey: bibleChannelKey,
          title: '📖 Time for Daily Bible Reading 🙏',
          body:
              'Take a moment to connect with God\'s Word today. You are loved!',
          payload: {'navigationPath': '/bible_reading_screen'},
          notificationLayout: NotificationLayout.BigText,
          summary: 'Daily Devotion',
          wakeUpScreen: true,
          category: NotificationCategory.Reminder,
        ),
        schedule: NotificationCalendar(
          hour: 12, // Changed to morning time (9 AM) instead of 11 PM
          minute: 0,
          second: 0,
          repeats: true,
          allowWhileIdle:
              true, // Will trigger even if device is in low-power mode
        ),
        actionButtons: [
          NotificationActionButton(key: 'OPEN_BIBLE', label: 'Open Bible'),
          NotificationActionButton(key: 'SNOOZE_BIBLE', label: 'Snooze'),
        ],
      );
    } catch (e) {
      // Silent fail for Bible reminder
      debugPrint('Failed to schedule Bible reminder: $e');
    }
  }

  Future<void> scheduleDailySummaryReminder() async {
    const int summaryReminderId = 300;
    const String summaryChannelKey = 'daily_summary';

    try {
      // Cancel any existing notifications first
      await AwesomeNotifications()
          .cancelNotificationsByChannelKey(summaryChannelKey);

      // Schedule the daily summary reminder at 11 PM
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: summaryReminderId,
          channelKey: summaryChannelKey,
          title: '✨ Reflect on Your Day ✨',
          body: 'Take a moment to jot down your thoughts about today. What went well? What are you grateful for?',
          payload: {'navigationPath': '/notes/new?type=daily_summary'},
          notificationLayout: NotificationLayout.BigText,
          summary: 'Daily Reflection',
          wakeUpScreen: true,
          category: NotificationCategory.Reminder,
        ),
        schedule: NotificationCalendar(
          hour: 23, // 11 PM
          minute: 0,
          second: 0,
          repeats: true,
          allowWhileIdle: true, // Will trigger even in low-power mode
          preciseAlarm: true, // Ensures the notification is delivered at the exact time
        ),
        actionButtons: [
          NotificationActionButton(key: 'ADD_NOTE', label: 'Add Summary'),
          NotificationActionButton(key: 'SNOOZE_SUMMARY', label: 'Remind Later'),
        ],
      );

      debugPrint('Daily summary reminder scheduled for 11:00 PM');
    } catch (e) {
      debugPrint('Failed to schedule daily summary reminder: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await AwesomeNotifications().cancel(id);
    } catch (_) {
      // Silent fail
    }
  }

  Future<void> cancelAllScheduledNotifications() async {
    try {
      await AwesomeNotifications().cancelAllSchedules();
    } catch (_) {
      // Silent fail
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await AwesomeNotifications().cancelAll();
    } catch (_) {
      // Silent fail
    }
  }

  static Future<void> initializeNotificationActionListeners() async {
    try {
      await AwesomeNotifications().setListeners(
        onActionReceivedMethod:
            NotificationActionController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationActionController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationActionController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationActionController.onDismissActionReceivedMethod,
      );
    } catch (e) {
      debugPrint('Failed to initialize notification listeners: $e');
    }
  }

  // Schedule all the app's notifications
  Future<void> scheduleAllNotifications() async {
    // Schedule the Bible reminder
    await scheduleDailyBibleReminder();
    
    // Schedule the daily summary reminder
    await scheduleDailySummaryReminder();
    
    // We don't need to schedule health notifications here as they're handled
    // by the health service directly
    
    debugPrint('All notifications scheduled successfully');
  }

  Future<bool> areNotificationsEnabled() async {
    return AwesomeNotifications().isNotificationAllowed();
  }

  static Future<ReceivedAction?> getInitialNotificationAction() async {
    try {
      return AwesomeNotifications()
          .getInitialNotificationAction(removeFromActionEvents: true);
    } catch (_) {
      return null;
    }
  }
}

class NotificationActionController {
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Minimal logic for production, or send to analytics
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Minimal logic for production, or send to analytics
  }

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Minimal logic for production, or send to analytics
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    final payload = receivedAction.payload;
    if (payload != null && payload.containsKey('navigationPath')) {
      final navigationPath = payload['navigationPath'];
      
      // Add any specific handling for the daily summary notification
      if (navigationPath == '/notes/new?type=daily_summary' && 
          receivedAction.buttonKeyPressed == 'ADD_NOTE') {
        // Logic to open the notes screen with a daily summary template
        // This will be handled by the app's navigation system when it's running
        debugPrint('User wants to add a daily summary note');
      }
      
      // Handle navigation or action based on payload
      // Ensure this logic is robust for background execution
    }

    if (receivedAction.buttonKeyPressed.isNotEmpty) {
      // Handle specific button actions
      if (receivedAction.buttonKeyPressed == 'SNOOZE_SUMMARY') {
        // Reschedule the reminder for 30 minutes later
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 301, // Different ID to avoid conflicts
            channelKey: 'daily_summary',
            title: '✨ Reflect on Your Day ✨',
            body: 'Take a moment to jot down your thoughts about today. What went well? What are you grateful for?',
            payload: {'navigationPath': '/notes/new?type=daily_summary'},
            notificationLayout: NotificationLayout.BigText,
            summary: 'Daily Reflection',
          ),
          schedule: NotificationCalendar(
            minute: DateTime.now().minute + 30 > 59 
                  ? (DateTime.now().minute + 30) % 60 
                  : DateTime.now().minute + 30,
            hour: DateTime.now().minute + 30 > 59 
                  ? (DateTime.now().hour + 1) % 24 
                  : DateTime.now().hour,
            second: 0,
            repeats: false,
            allowWhileIdle: true,
          ),
        );
        debugPrint('Daily summary reminder snoozed for 30 minutes');
      }
    }
  }
}
