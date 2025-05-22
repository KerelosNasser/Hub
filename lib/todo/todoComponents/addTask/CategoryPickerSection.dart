import 'package:flutter/material.dart';

class CategoryPickerSection extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const CategoryPickerSection({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        dropdownColor: Colors.white,
        decoration: const InputDecoration(
          labelText: 'Category',
          border: InputBorder.none,
        ),
        items: ['All', 'General', 'Work', 'Personal', 'Shopping']
            .map((category) => DropdownMenuItem<String>(
          value: category,
          child: Text(
            category,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            onCategoryChanged(value); // Pass the selected category back
          }
        },
      ),
    );
  }
}
