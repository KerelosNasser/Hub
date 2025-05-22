import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'TaskModels/task_model.dart';

class TaskController extends GetxController {
  var tasks = <Task>[].obs;
  var filteredTasks = <Task>[].obs;
  late Box<Task> taskBox;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void onInit() async {
    super.onInit();
    await openTaskBox();
    loadTasks();
  }

  Future<void> openTaskBox() async {
    taskBox = await Hive.openBox<Task>('tasks');
  }

  void loadTasks() {
    tasks.assignAll(taskBox.values.toList());
    filteredTasks.assignAll(tasks);
  }

  void addTask(Task task) {
    taskBox.add(task);
    loadTasks();
  }

  void updateTask(Task task) {
    task.save();
    loadTasks();
  }

  void deleteTask(Task task) {
    task.delete();
    loadTasks();
  }

}
