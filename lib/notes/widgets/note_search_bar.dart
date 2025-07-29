import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoteSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final RxString searchQuery;
  final VoidCallback onClear;
  final VoidCallback onDateFilter;
  final VoidCallback onRefresh;

  const NoteSearchBar({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.onClear,
    required this.onDateFilter,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.pink.shade700,
      padding: EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGoogleSearchBar(context),
        ],
      ),
    );
  }

  Widget _buildGoogleSearchBar(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.pinkAccent.shade700,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search icon
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(
              Icons.search,
              color: Colors.white,
              size: 24,
            ),
          ),

          // Search input field
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Search your notes...',
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),

          // Clear button if text is entered
          Obx(() => searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: onClear,
                )
              : SizedBox.shrink()),

          // Vertical divider
          Container(
            height: 24,
            width: 1,
            color: Colors.white,
            margin: EdgeInsets.symmetric(horizontal: 8),
          ),

          // Date filter button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: onDateFilter,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // Refresh button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: onRefresh,
              child: Padding(
                padding: EdgeInsets.fromLTRB(8, 12, 16, 12),
                child: Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
