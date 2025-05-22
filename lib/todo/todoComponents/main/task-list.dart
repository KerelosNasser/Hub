import 'package:farahs_hub/todo/todoComponents/main/task-tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../task controller.dart';

class TaskList extends StatelessWidget {
  final DateTime selectedDate;

  const TaskList({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find();

    return Obx(() {
      final tasksForSelectedDate = taskController.tasks.where((task) =>
      DateFormat.yMd().format(task.dateTime) ==
          DateFormat.yMd().format(selectedDate)).toList();

      if (tasksForSelectedDate.isEmpty) {
        return const Center(child: Text('No tasks for the selected date',style: TextStyle(color: Colors.white,fontSize: 19),));
      }

      return ListView.builder(
        itemCount: tasksForSelectedDate.length,
        itemBuilder: (context, index) {
          final task = tasksForSelectedDate[index];
          final time = DateFormat.jm().format(task.dateTime);

          return TaskListTile(task: task, time: time);
        },
      );
    });
  }
}
