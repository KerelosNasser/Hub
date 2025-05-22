import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../TaskModels/task_model.dart';
import '../notification-controller.dart';
import '../task controller.dart';
import '../todoComponents/addTask/DatePickerSection.dart';
import '../todoComponents/addTask/Task-Title-Section.dart';
import '../todoComponents/addTask/TaskDescriptionSection.dart';
import '../todoComponents/addTask/TimePickerSection.dart';
import '../todoComponents/addTask/icon-section.dart';


class AddTaskPage extends StatelessWidget {
  final TaskController taskController = Get.find();
  final NotificationController notificationController = Get.put(NotificationController()); // Use GetX for NotificationController
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  AddTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade800,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: context.mediaQuerySize.height * 0.1),
              const IconSection(),
              SizedBox(height: context.mediaQuerySize.height * 0.03),
              TaskTitleSection(titleController: titleController),
              SizedBox(height: context.mediaQuerySize.height * 0.01),
              TaskDescriptionSection(descriptionController: descriptionController),
              SizedBox(height: context.mediaQuerySize.height * 0.03),
              DatePickerSection(
                selectedDate: selectedDate,
                onDatePicked: (newDate) {
                  selectedDate = newDate;
                },
              ),
              SizedBox(height: context.mediaQuerySize.height * 0.01),
              TimePickerSection(
                selectedTime: selectedTime,
                onTimePicked: (newTime) {
                  selectedTime = newTime;
                },
              ),
              SizedBox(height: context.mediaQuerySize.height * 0.03),
              ElevatedButton(
                onPressed: () async {
                  // Validate fields
                  if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
                    Get.snackbar(
                      'Error',
                      'Please fill in all fields',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  final task = Task(
                    id: DateTime.now().toString(),
                    title: titleController.text,
                    description: descriptionController.text,
                    dateTime: DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    ),
                    isCompleted: false,
                  );

                  taskController.addTask(task);
                  Get.back();
                  try {
                    await notificationController.scheduleNotification(
                      task,
                      selectedDate,
                      selectedTime,
                    );

                    Get.snackbar(
                      'Success',
                      'Task added and notification scheduled',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Failed to schedule notification: $e',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 13),
                  backgroundColor: Color(0xffedf3ff),
                ),
                child: Text(
                  'Add Task',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    color: Colors.pink.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
