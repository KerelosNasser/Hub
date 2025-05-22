import 'package:flutter/material.dart';

import 'CustomTextFormField.dart';

class TaskDescriptionSection extends StatelessWidget {
  final TextEditingController descriptionController;
  const TaskDescriptionSection({super.key, required this.descriptionController});

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: descriptionController,
      label: 'Task Description',
      maxLines: 5,
    );
  }
}
