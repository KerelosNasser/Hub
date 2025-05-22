import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarSection extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarSection({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  late CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffedf3ff),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2000, 1, 1),
        lastDay: DateTime.utc(2100, 12, 31),
        focusedDay: widget.selectedDate,
        selectedDayPredicate: (day) => isSameDay(widget.selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          widget.onDateSelected(selectedDay);
        },
        calendarFormat: _calendarFormat,
        onFormatChanged: (CalendarFormat format) {
          if (format != _calendarFormat) {
            setState(() {
              _calendarFormat = format; // Update the format when it changes
            });
          }
        },
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: true,
          titleTextStyle: TextStyle(
            color: Colors.pink.shade800,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.pink.shade800),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.pink.shade800),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekendStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          weekdayStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          weekendTextStyle: TextStyle(color: Colors.pink.shade800, fontSize: 16),
          defaultTextStyle: TextStyle(color: Colors.pink.shade800, fontSize: 16),
          cellMargin: const EdgeInsets.all(4.0),
        ),
      ),
    );
  }
}
