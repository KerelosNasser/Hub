import 'package:flutter/material.dart';

enum EmptyStateType {
  noNotes,
  noMatchingNotes,
  error,
}

class NotesEmptyState extends StatelessWidget {
  final EmptyStateType type;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool hasSearchQuery;
  final bool hasDateFilter;

  const NotesEmptyState({
    Key? key,
    required this.type,
    this.errorMessage,
    this.onRetry,
    this.hasSearchQuery = false,
    this.hasDateFilter = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              _getIcon(),
              color: Colors.white70,
              size: 80,
            ),
            SizedBox(height: 24),
            
            // Title
            Text(
              _getTitle(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            
            // Subtitle
            Text(
              _getSubtitle(),
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Retry button for error state
            if (type == EmptyStateType.error && onRetry != null)
              Padding(
                padding: EdgeInsets.only(top: 32),
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: Icon(Icons.refresh),
                  label: Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.pink.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case EmptyStateType.noNotes:
        return Icons.note_alt_outlined;
      case EmptyStateType.noMatchingNotes:
        return Icons.search_off;
      case EmptyStateType.error:
        return Icons.error_outline;
    }
  }

  String _getTitle() {
    switch (type) {
      case EmptyStateType.noNotes:
        return 'No Notes Yet';
      case EmptyStateType.noMatchingNotes:
        return 'No Matching Notes Found';
      case EmptyStateType.error:
        return 'Error Loading Notes';
    }
  }

  String _getSubtitle() {
    switch (type) {
      case EmptyStateType.noNotes:
        return 'Tap the + button to create your first note';
      case EmptyStateType.noMatchingNotes:
        if (hasSearchQuery && hasDateFilter) {
          return 'Try changing your search term or clearing the date filter';
        } else if (hasSearchQuery) {
          return 'Try using different search terms';
        } else if (hasDateFilter) {
          return 'No notes found for the selected date. Try selecting a different date';
        }
        return 'Try a different search';
      case EmptyStateType.error:
        return errorMessage ?? 'Something went wrong while loading your notes';
    }
  }
}
