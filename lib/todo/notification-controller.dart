
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'TaskModels/task_model.dart';

Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  if (receivedAction.payload != null && receivedAction.payload!['navigate'] != null) {
    Get.toNamed(receivedAction.payload!['navigate']!);
  }
}

class NotificationController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _setNotificationListeners();
    _requestNotificationPermissions();
  }


  void _setNotificationListeners() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  void _requestNotificationPermissions() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  void triggerNotification(String title, String body, String routeName) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        title: title,
        body: body,
        payload: {'navigate': routeName},
      ),
    );
  }

  Future<void> scheduleNotification(Task task, DateTime selectedDate, TimeOfDay selectedTime) async {
    try {
      DateTime scheduledDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: task.id.hashCode,
          channelKey: 'basic_channel',
          title: task.title,
          body: task.description,
          notificationLayout: NotificationLayout.BigText,
          roundedLargeIcon: isAllowed,
          displayOnBackground: true,
          displayOnForeground: true,
          icon: 'resource://drawable/ic_notification',
          backgroundColor: Colors.transparent
        ),
        schedule: NotificationCalendar.fromDate(
          date: scheduledDateTime,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );

    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }
}
