import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../task controller.dart';

class TaskListTile extends StatelessWidget {
  final task;
  final String time;

  const TaskListTile({super.key, required this.task, required this.time});

  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Adjust font size and padding based on screen width
    double titleFontSize = screenWidth * 0.06; // 6% of screen width
    double subtitleFontSize = screenWidth * 0.045; // 4.5% of screen width
    double paddingHorizontal = screenWidth * 0.06; // 6% of screen width

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Slightly increased margin for better spacing
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: const Color(0xffedf3ff),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: titleFontSize,
            color: Colors.pink.shade800,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Due: $time',
              style: TextStyle(
                fontSize: subtitleFontSize,
                color: Colors.pink.shade800,
              ),
            ),
            Text(
              'Description: ${task.description}',
              style: TextStyle(
                fontSize: subtitleFontSize,
                color: Colors.pink.shade800,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () => Get.find<TaskController>().deleteTask(task),
        ),
      ),
    );
  }
}
