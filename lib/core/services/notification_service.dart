import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  Future<NotificationService> init() async {
    try {
      await AwesomeNotifications().initialize(
        'resource://drawable/ic_notification',
        [
          NotificationChannel(
            channelKey: 'app_notifications',
            channelName: 'App Notifications',
            channelDescription: 'General notifications for the app.',
            importance: NotificationImportance.High,
            defaultRingtoneType: DefaultRingtoneType.Notification,
            playSound: true,
            enableVibration: true,
          ),
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
          )
        ],
        debug: false, // Set to false for production
      );

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
    } catch (e) {
      Get.snackbar(
        'Notification Setup Error',
        'Could not initialize notifications. Some alert features might not work as expected.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
    } catch (e) {
      Get.snackbar(
        'Scheduling Error',
        'Could not schedule notification: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> scheduleDailyBibleReminder() async {
    const int bibleReminderId = 100;
    const String bibleChannelKey = 'bible_reminder';

    try {
      await AwesomeNotifications()
          .cancelNotificationsByChannelKey(bibleChannelKey);

      await scheduleNotification(
          id: bibleReminderId,
          channelKey: bibleChannelKey,
          title: '📖 Time for Daily Bible Reading 🙏',
          body:
              'Take a moment to connect with God\'s Word today. You are loved!',
          payload: {'navigationPath': '/bible_reading_screen'},
          notificationLayout: NotificationLayout.BigText,
          summary: 'Daily Devotion',
          schedule: NotificationCalendar(
            hour: 23,
            minute: 0,
            second: 0,
            repeats: true,
          ),
          actionButtons: [
            NotificationActionButton(
                key: 'MARK_AS_READ', label: 'Mark as Read'),
            NotificationActionButton(
                key: 'SNOOZE_BIBLE', label: 'Snooze for 1 Hour'),
          ]);
    } catch (e) {
      Get.snackbar(
        'Reminder Setup Error',
        'Failed to schedule daily Bible reminder.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await AwesomeNotifications().cancel(id);
    } catch (e) {
      // Optionally log this error to a more persistent logging service in production
    }
  }

  Future<void> cancelAllScheduledNotifications() async {
    try {
      await AwesomeNotifications().cancelAllSchedules();
    } catch (e) {
      // Optionally log
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await AwesomeNotifications().cancelAll();
    } catch (e) {
      // Optionally log
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
      // Optionally log
    }
  }

  Future<bool> areNotificationsEnabled() async {
    return AwesomeNotifications().isNotificationAllowed();
  }

  static Future<ReceivedAction?> getInitialNotificationAction() async {
    try {
      return AwesomeNotifications()
          .getInitialNotificationAction(removeFromActionEvents: true);
    } catch (e) {
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
      // Handle navigation or action based on payload
      // Ensure this logic is robust for background execution
    }

    if (receivedAction.buttonKeyPressed.isNotEmpty) {
      // Handle button presses
    }
  }
}
