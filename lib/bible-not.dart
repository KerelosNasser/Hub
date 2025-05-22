import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initNotification() async {

    await AwesomeNotifications().setChannel(
      NotificationChannel(
        channelKey: 'bible_reminder',
        channelName: 'Bible Reading Reminders',
        channelDescription: 'Daily reminders to read the Bible',
        importance: NotificationImportance.High,
        defaultRingtoneType: DefaultRingtoneType.Notification,
        locked: true,
        criticalAlerts: true,
        icon: 'resource://drawable/ic_notification',
        enableVibration: true,
      ),
    );
  }

  Future<void> scheduleDailyBibleReminder() async {
    await AwesomeNotifications().cancelNotificationsByChannelKey('bible_reminder');

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
        icon: 'resource://drawable/ic_notification',
        criticalAlert: true,
      ),
      schedule: NotificationCalendar(
        hour: 23,
        minute: 0,
        second: 0,
        millisecond: 0,
        repeats: true,
        allowWhileIdle: true,
        preciseAlarm: true,

      ),
    );
  }
}