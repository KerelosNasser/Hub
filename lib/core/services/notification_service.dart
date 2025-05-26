import 'package:awesome_notifications/awesome_notifications.dart';
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
            channelDescription: 'All app notifications',
            importance: NotificationImportance.High,
            defaultRingtoneType: DefaultRingtoneType.Notification,
          ),
          NotificationChannel(
            channelKey: 'bible_reminder',
            channelName: 'Bible Reading Reminders',
            channelDescription: 'Daily reminders to read the Bible',
            importance: NotificationImportance.High,
            defaultRingtoneType: DefaultRingtoneType.Notification,
            locked: true,
            criticalAlerts: true,
            enableVibration: true,
          ),
        ],
      );
      return this;
    } catch (e) {
      Get.snackbar('Error', 'Failed to initialize notifications: $e');
      rethrow;
    }
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required String channelKey,
    required int id,
    required NotificationCalendar schedule,
  }) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: channelKey,
          title: title,
          body: body,
        ),
        schedule: schedule,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to schedule notification: $e');
      rethrow;
    }
  }

  Future<void> scheduleDailyBibleReminder() async {
    try {
      await AwesomeNotifications()
          .cancelNotificationsByChannelKey('bible_reminder');

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 100,
          channelKey: 'bible_reminder',
          title: 'Time for Daily Bible Reading',
          body: 'Take a moment to connect with God\'s Word today',
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          fullScreenIntent: true,
          autoDismissible: false,
          criticalAlert: true,
        ),
        schedule: NotificationCalendar(
          hour: 23,
          minute: 0,
          second: 0,
          millisecond: 0,
          repeats: true,
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to schedule Bible reminder: $e');
      rethrow;
    }
  }
}
