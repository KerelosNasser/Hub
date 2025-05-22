import 'package:flutter/material.dart';

import 'CustomTextFormField.dart';

class TaskTitleSection extends StatelessWidget {
  final TextEditingController titleController;
  const TaskTitleSection({super.key, required this.titleController});

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: titleController,
      label: 'Task Title',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a task title';
        }
        return null;
      },
    );
  }
}
