import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../views/note_edit_screen.dart';

class NoteGridItem extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete;

  const NoteGridItem({
    Key? key,
    required this.note,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert the color hex string to a Color
    final Color noteColor = _getColorFromHex(note.color);

    return GestureDetector(
      onTap: () => Get.to(
        () => NoteEditScreen(noteId: note.id),
        transition: Transition.cupertino,
      ),
      onLongPress: () => _showOptionsDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.pink.shade800,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title section with color indicator
                Container(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Color indicator
                      Container(
                        width: 12,
                        height: 12,
                        margin: EdgeInsets.only(top: 4, right: 8),
                        decoration: BoxDecoration(
                          color: noteColor,
                          shape: BoxShape.circle,
                        ),
                      ),

                      // Title with max 2 lines
                      Expanded(
                        child: Text(
                          note.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Date
                Padding(
                  padding: EdgeInsets.only(left: 32, right: 12, bottom: 8),
                  child: Text(
                    _formatDate(note.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),

                // Description preview (max 1 line)
                if (note.description.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      note.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                // First image if available
                if (note.imagePaths.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      child: Image.file(
                        File(note.imagePaths.first),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                // Drawing preview if available and no images
                else if (note.drawingPath != null &&
                    note.drawingPath!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      child: Image.file(
                        File(note.drawingPath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                // Spacing at bottom
                SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        color: Colors.pink.shade900,
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: Colors.white),
              title: Text('Edit Note'),
              onTap: () {
                Navigator.pop(context);
                Get.to(
                  () => NoteEditScreen(noteId: note.id),
                  transition: Transition.cupertino,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.white),
              title: Text('Delete Note'),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
