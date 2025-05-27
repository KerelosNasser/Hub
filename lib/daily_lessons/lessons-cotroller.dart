import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:farahs_hub/core/services/notification_service.dart';

import 'lesson-repo.dart';
import 'lessons_model.dart';

class LessonController extends GetxController {
  final LessonRepository _repository = LessonRepository();
  final GetStorage _storage = GetStorage();
  late final NotificationService _notificationService;

  RxList<LessonModel> dailyLessons = <LessonModel>[].obs;
  RxBool isLessonAvailable = false.obs;

  @override
  void onInit() {
    super.onInit();
    _notificationService = Get.find<NotificationService>();
    _requestNotificationPermissions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadOrRefreshLessons();
    });
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
    String? lastLessonDateString = _storage.read('last_lesson_date');
    DateTime? lastLessonDate;
    if (lastLessonDateString != null) {
      lastLessonDate = DateTime.tryParse(lastLessonDateString);
    }

    if (lastLessonDate == null || !_isSameDay(lastLessonDate, DateTime.now())) {
      dailyLessons.value = _repository.getDailyLessons();
      _storage.write('last_lesson_date', DateTime.now().toIso8601String());
      isLessonAvailable.value = true;
      _scheduleDailyNotification();
    } else {
      if (dailyLessons.isEmpty && _isSameDay(lastLessonDate, DateTime.now())) {
        dailyLessons.value = _repository.getDailyLessons();
        isLessonAvailable.value = true;
      } else if (dailyLessons.isNotEmpty) {
        isLessonAvailable.value = true;
      }
    }
  }

  void _scheduleDailyNotification() {
    _notificationService.scheduleNotification(
      title: 'New Daily Lessons! 📚',
      body: "Don't forget to take at Least one lesson",
      channelKey: 'daily_lessons',
      id: 10,
      schedule: NotificationCalendar(
        hour: 18,
        minute: 0,
        second: 0,
        repeats: true,
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
