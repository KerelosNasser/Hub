import 'package:flutter/material.dart';

class TimePickerSection extends StatelessWidget {
  final TimeOfDay selectedTime;
  final Function(TimeOfDay) onTimePicked;

  const TimePickerSection({
    super.key,
    required this.selectedTime,
    required this.onTimePicked,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Due Time: ${selectedTime.format(context)}',
            style: TextStyle(
              fontSize: screenWidth * 0.05, // Responsive font size
              color: const Color(0xffedf3ff),
            ),
            overflow: TextOverflow.ellipsis, // Prevent overflow
          ),
        ),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: selectedTime,
            );
            if (picked != null && picked != selectedTime) {
              onTimePicked(picked);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06, // Responsive horizontal padding
              vertical: screenWidth * 0.04, // Responsive vertical padding
            ),
            decoration: BoxDecoration(
              color: const Color(0xffedf3ff),
              borderRadius: BorderRadius.circular(screenWidth * 0.06), // Responsive border radius
              border: Border.all(color: Colors.pink.shade800),
            ),
            child: Text(
              'Pick Time',
              style: TextStyle(
                fontSize: screenWidth * 0.045, // Responsive font size
                color: Colors.pink.shade800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
