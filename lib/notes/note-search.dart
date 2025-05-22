import 'package:intl/intl.dart';

class NoteSearchService {
  static final List<DateFormat> _dateFormats = [
    DateFormat('MMM d, yyyy'),
    DateFormat('MMM d'),
    DateFormat('MM/dd/yyyy'),
    DateFormat('MM/dd'),
    DateFormat('dd/MM/yyyy'),
    DateFormat('dd/MM'),
    DateFormat('yyyy-MM-dd'),
    DateFormat.yMMMd(),
    DateFormat.yMd(),
    DateFormat.yMMMM(),
    DateFormat.yM(),
  ];

  static DateTime? tryParseDate(String input) {
    input = input.trim();

    // Try to parse using various date formats
    for (var format in _dateFormats) {
      try {
        return format.parse(input);
      } catch (_) {
        // Continue to next format if parsing fails
      }
    }

    // Handle relative date terms
    final now = DateTime.now();
    final lowercaseInput = input.toLowerCase();

    switch (lowercaseInput) {
      case 'today':
        return DateTime(now.year, now.month, now.day);
      case 'yesterday':
        return DateTime(now.year, now.month, now.day - 1);
      case 'this week':
        return DateTime(now.year, now.month, now.day - now.weekday);
      case 'last week':
        return DateTime(now.year, now.month, now.day - now.weekday - 7);
      case 'this month':
        return DateTime(now.year, now.month, 1);
      case 'last month':
        return DateTime(now.year, now.month - 1, 1);
      default:
      // Try to parse month names
        final months = {
          'january': 1, 'february': 2, 'march': 3, 'april': 4,
          'may': 5, 'june': 6, 'july': 7, 'august': 8,
          'september': 9, 'october': 10, 'november': 11, 'december': 12
        };

        for (var entry in months.entries) {
          if (lowercaseInput.contains(entry.key)) {
            return DateTime(now.year, entry.value, 1);
          }
        }
    }

    return null;
  }

  static bool _dateMatches(DateTime noteDate, DateTime searchDate) {
    return noteDate.year == searchDate.year &&
        noteDate.month == searchDate.month &&
        noteDate.day == searchDate.day;
  }

  static List filterNotes(List notes, String query) {
    if (query.isEmpty) return notes;

    final searchLower = query.toLowerCase();
    final searchDate = tryParseDate(query);

    return notes.where((note) {
      // Search by title
      if (note.title.toLowerCase().contains(searchLower)) {
        return true;
      }

      // Search by date if we successfully parsed a date
      if (searchDate != null) {
        return _dateMatches(note.createdAt, searchDate);
      }

      return false;
    }).toList();
  }
}