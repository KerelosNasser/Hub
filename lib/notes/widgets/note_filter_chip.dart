import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteDateFilterChip extends StatelessWidget {
  final DateTime date;
  final VoidCallback onClear;

  const NoteDateFilterChip({
    Key? key,
    required this.date,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8, left: 16, right: 16),
      child: Chip(
        backgroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelPadding: EdgeInsets.symmetric(horizontal: 8),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: Colors.pink.shade700,
            ),
            SizedBox(width: 6),
            Text(
              'Date: ${DateFormat('MMM d, yyyy').format(date)}',
              style: TextStyle(
                color: Colors.pink.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        deleteIcon: Icon(
          Icons.close,
          size: 16,
          color: Colors.pink.shade700,
        ),
        onDeleted: onClear,
      ),
    );
  }
}
