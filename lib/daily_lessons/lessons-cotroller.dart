import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'lesson-repo.dart';
import 'lessons_model.dart';

class LessonController extends GetxController {
  final LessonRepository _repository = LessonRepository();
  final GetStorage _storage = GetStorage();

  RxList<LessonModel> dailyLessons = <LessonModel>[].obs;
  RxBool isLessonAvailable = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize notification permissions
    _requestNotificationPermissions();
    loadOrRefreshLessons();
  }

  void _requestNotificationPermissions() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications(
          permissions: [
            NotificationPermission.Alert,
            NotificationPermission.Sound,
            NotificationPermission.Badge,
            NotificationPermission.Vibration,
          ],
        );
      }
    });
  }

  void loadOrRefreshLessons() {
    // Check if lessons need refresh
    DateTime? lastLessonDate = _storage.read('last_lesson_date');

    if (lastLessonDate == null ||
        !_isSameDay(lastLessonDate, DateTime.now())) {
      // Generate new daily lessons
      dailyLessons.value = _repository.getDailyLessons();

      // Save current date
      _storage.write('last_lesson_date', DateTime.now());

      // Update lesson availability
      isLessonAvailable.value = true;

      // Schedule daily notification
      _scheduleDailyNotification();
    }
  }

  void _scheduleDailyNotification() {
    // Cancel previous scheduled notifications
    AwesomeNotifications().cancelAllSchedules();

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'daily_lessons',
        title: 'New Daily Lessons! 📚',
        body: "Don't forget to take at Least one lesson",
        icon: 'resource://drawable/ic_notification',
          criticalAlert: true,

      ),
      schedule: NotificationCalendar(
        hour: 18,
        minute: 0,
        second: 0,
        repeats: true,
        preciseAlarm: true,
        allowWhileIdle: true
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year &&
        d1.month == d2.month &&
        d1.day == d2.day;
  }
}

