import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../task controller.dart';
import '../todoComponents/main/calendar.dart';
import '../todoComponents/main/task-list.dart';
import 'add task.dart';

class ToDoPage extends StatefulWidget {
  const ToDoPage({super.key});

 @override
_ToDoPageState createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  final TaskController taskController = Get.put(TaskController());
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade800,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: CalendarSection(
              selectedDate: _selectedDate,
              onDateSelected: (selectedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
              },
            ),
          ),

           SizedBox(height: context.mediaQuerySize.height *.02),
          // Task List
          Expanded(
            child: TaskList(
              selectedDate: _selectedDate,
            ),),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(21.0),
        child: FloatingActionButton(
          heroTag: 'fab2',
          tooltip: 'Add Task',
          backgroundColor: Color(0xffedf3ff),
          shape: const CircleBorder(),
          elevation: 10,
          onPressed: () => Get.to(() => AddTaskPage()),
          child: Icon(Icons.add,color: Colors.pink.shade800,size: 35,weight: 900,),
        ),
      ),
    );
  }
}
