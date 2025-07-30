import 'package:farahs_hub/notes/widgets/backup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/note_controller.dart';
import '../models/note_model.dart';
import '../views/note_edit_screen.dart';
import '../widgets/note_search_bar.dart';
import '../widgets/note_filter_chip.dart';
import '../widgets/notes_staggered_grid.dart';
import '../widgets/notes_empty_state.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final NoteController _noteController = Get.put(NoteController());
  final TextEditingController _searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxBool showSyncWidget = false.obs;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    searchQuery.value = _searchController.text;
  }

  void _clearSearch() {
    _searchController.clear();
    searchQuery.value = '';
  }

  void _clearDateFilter() {
    selectedDate.value = null;
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.pink.shade700,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  void _refreshNotes() {
    _noteController.loadNotes();
    _noteController.checkConnectionStatus();
  }

  void _confirmDeleteNote(Note note) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Note'),
        content: Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _noteController.deleteNote(note.id!);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade700,
      body: Column(
        children: [
          // Search bar at top
          NoteSearchBar(
            controller: _searchController,
            searchQuery: searchQuery,
            onClear: _clearSearch,
            onDateFilter: _selectDate,
            onRefresh: _refreshNotes,
          ),

          // Sync status indicator (always visible, compact)
          Obx(() => _buildSyncStatusBar()),

          // Date filter chip (only shows when date is selected)
          Obx(() => selectedDate.value != null
              ? NoteDateFilterChip(
                  date: selectedDate.value!,
                  onClear: _clearDateFilter,
                )
              : SizedBox.shrink()),

          // Expandable Sync Widget
          Obx(() => AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: showSyncWidget.value ? null : 0,
            child: showSyncWidget.value
                ? SyncBackupWidget(noteController: _noteController)
                : SizedBox.shrink(),
          )),

          // Notes content
          Expanded(
            child: Obx(() {
              // Loading state
              if (_noteController.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.pink.shade400,
                  ),
                );
              }

              // Error state
              if (_noteController.hasError.value) {
                return NotesEmptyState(
                  type: EmptyStateType.error,
                  errorMessage: _noteController.errorMessage.value,
                  onRetry: _refreshNotes,
                );
              }

              // Filter notes based on search and date
              List<Note> filteredNotes = _noteController.notes;

              // Apply search filter
              if (searchQuery.value.isNotEmpty) {
                final query = searchQuery.value.toLowerCase();
                filteredNotes = filteredNotes.where((note) {
                  return note.title.toLowerCase().contains(query) ||
                      note.description.toLowerCase().contains(query);
                }).toList();
              }

              // Apply date filter
              if (selectedDate.value != null) {
                final date = selectedDate.value!;
                final startOfDay = DateTime(date.year, date.month, date.day);
                final endOfDay =
                    DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

                filteredNotes = filteredNotes.where((note) {
                  return note.createdAt.isAfter(startOfDay) &&
                      note.createdAt.isBefore(endOfDay);
                }).toList();
              }

              // Empty state (no notes at all)
              if (_noteController.notes.isEmpty) {
                return NotesEmptyState(
                  type: EmptyStateType.noNotes,
                );
              }

              // No matching notes after filtering
              if (filteredNotes.isEmpty) {
                return NotesEmptyState(
                  type: EmptyStateType.noMatchingNotes,
                  hasSearchQuery: searchQuery.value.isNotEmpty,
                  hasDateFilter: selectedDate.value != null,
                );
              }

              // Notes staggered grid
              return NotesStaggeredGrid(
                notes: filteredNotes,
                onDeleteNote: _confirmDeleteNote,
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Sync status FAB
          Obx(() => FloatingActionButton.small(
            onPressed: () => showSyncWidget.value = !showSyncWidget.value,
            backgroundColor: _noteController.hasUnsyncedNotes 
                ? Colors.orange.shade600 
                : Colors.green.shade600,
            child: Icon(
              showSyncWidget.value ? Icons.keyboard_arrow_up : Icons.cloud_queue,
              color: Colors.white,
            ),
            heroTag: "sync_fab",
          )),
          SizedBox(height: 12),
          // Add note FAB
          FloatingActionButton(
            onPressed: () => Get.to(() => NoteEditScreen()),
            backgroundColor: Colors.pink.shade700,
            child: Icon(Icons.add, color: Colors.white),
            heroTag: "add_fab",
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatusBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.pink.shade800,
      child: Row(
        children: [
          // Connection status
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _noteController.isOnline.value ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          
          // Sync status text
          Expanded(
            child: Text(
              _noteController.syncStatusText,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
          
          // Sync progress indicator
          if (_noteController.isSyncing.value)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
            ),
          
          // Unsync indicator
          if (_noteController.hasUnsyncedNotes && !_noteController.isSyncing.value)
            Icon(
              Icons.cloud_off,
              color: Colors.orange.shade300,
              size: 16,
            ),
        ],
      ),
    );
  }
}