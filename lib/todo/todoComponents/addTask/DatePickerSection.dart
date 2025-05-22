import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerSection extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDatePicked;

  const DatePickerSection({
    super.key,
    required this.selectedDate,
    required this.onDatePicked,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Due Date: ${DateFormat.yMd().format(selectedDate)}',
            style: TextStyle(
              fontSize: screenWidth * 0.05, // Adjust font size
              color: const Color(0xffedf3ff),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (picked != null && picked != selectedDate) {
              onDatePicked(picked);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06, // Adjust horizontal padding
              vertical: screenWidth * 0.04, // Adjust vertical padding
            ),
            decoration: BoxDecoration(
              color: const Color(0xffedf3ff),
              borderRadius: BorderRadius.circular(screenWidth * 0.06), // Adjust border radius
              border: Border.all(color: Colors.pink.shade800),
            ),
            child: Text(
              'Pick Date',
              style: TextStyle(
                fontSize: screenWidth * 0.045, // Adjust font size
                color: Colors.pink.shade800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
