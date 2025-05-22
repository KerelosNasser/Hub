import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DateTimeSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final RxString searchQuery;
  final bool isSmallScreen;
  final VoidCallback onClearSearch;

  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);

  DateTimeSearchBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.isSmallScreen,
    required this.onClearSearch,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.pink.shade800,
              onPrimary: const Color(0xffedf3ff),
              surface: Colors.pink.shade900,
              onSurface: const Color(0xffedf3ff),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedDate.value = picked;
      _updateSearchQuery();
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.pink.shade800,
              onPrimary: const Color(0xffedf3ff),
              surface: Colors.pink.shade900,
              onSurface: const Color(0xffedf3ff),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedTime.value = picked;
      _updateSearchQuery();
    }
  }

  void _updateSearchQuery() {
    if (selectedDate.value != null) {
      final date = DateFormat('MMM d, yyyy').format(selectedDate.value!);
      if (selectedTime.value != null) {
        final time = selectedTime.value!.format(Get.context!);
        searchQuery.value = '$date $time';
      } else {
        searchQuery.value = date;
      }
      searchController.text = searchQuery.value;
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    selectedDate.value = null;
    selectedTime.value = null;
    onClearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            onChanged: (value) => searchQuery.value = value,
            style: TextStyle(
              color: const Color(0xffedf3ff),
              fontSize: isSmallScreen ? 14 : 18,
            ),
            decoration: InputDecoration(
              hintText: 'Search by title',
              hintStyle: TextStyle(
                color: const Color(0xffedf3ff).withOpacity(0.7),
                fontSize: isSmallScreen ? 14 : 18,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: const Color(0xffedf3ff),
                size: isSmallScreen ? 20 : 28,
              ),
              suffixIcon: Obx(
                    () => searchQuery.value.isNotEmpty
                    ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: const Color(0xffedf3ff),
                    size: isSmallScreen ? 20 : 28,
                  ),
                  onPressed: clearSearch,
                )
                    : const SizedBox.shrink(),
              ),
              filled: true,
              fillColor: Colors.pink.shade900,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 20,
                vertical: isSmallScreen ? 12 : 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.pink.shade900,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.calendar_today,
                  color: const Color(0xffedf3ff),
                  size: isSmallScreen ? 20 : 28,
                ),
                onPressed: () => _selectDate(context),
              ),
              IconButton(
                icon: Icon(
                  Icons.access_time,
                  color: const Color(0xffedf3ff),
                  size: isSmallScreen ? 20 : 28,
                ),
                onPressed: () => _selectTime(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}