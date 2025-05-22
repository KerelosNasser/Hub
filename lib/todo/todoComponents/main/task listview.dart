import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../task controller.dart';

class TaskListView extends StatelessWidget {
  final DateTime selectedDate;
  TaskListView(this.selectedDate, {super.key});

  final TaskController taskController = Get.find();

  @override
  Widget build(BuildContext context) {
    final tasksForSelectedDate = taskController.tasks.where((task) =>
    task.dateTime.day == selectedDate.day &&
        task.dateTime.month == selectedDate.month &&
        task.dateTime.year == selectedDate.year);

    return Scaffold(
      appBar: AppBar(title: Text('Tasks for ${selectedDate.toLocal()}')),
      body: Obx(() => ListView.builder(
        itemCount: tasksForSelectedDate.length,
        itemBuilder: (context, index) {
          final task = tasksForSelectedDate.elementAt(index);
          return ListTile(
            title: Text(task.title),
            subtitle: Text(task.description),
            trailing: Text('${task.dateTime.hour}:${task.dateTime.minute}'),
          );
        },
      )),
    );
  }
}
