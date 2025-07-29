import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../controllers/note_controller.dart';
import 'note_edit_screen.dart';

class NoteMemoryFrame extends StatelessWidget {
  final Note note;

  const NoteMemoryFrame({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final Color noteColor = _getColorFromHex(note.color);
    
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white, size: 24),
            onPressed: () => Get.to(() => NoteEditScreen(noteId: note.id)),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white, size: 24),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Polaroid-style image section
                  Container(
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildImageSection(),
                  ),
                  
                  // Content section
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          note.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        SizedBox(height: 8),
                        
                        // Date with color indicator
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: noteColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              DateFormat('MMMM d, yyyy').format(note.createdAt),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 12),
                        
                        // Description
                        if (note.description.isNotEmpty)
                          Text(
                            note.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    if (note.imagePaths.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(note.imagePaths.first),
          fit: BoxFit.cover,
          width: double.infinity,
          height: 300,
        ),
      );
    } else if (note.drawingPath != null && note.drawingPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(note.drawingPath!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: 300,
        ),
      );
    } else {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_outlined, size: 48, color: Colors.grey.shade400),
              SizedBox(height: 8),
              Text(
                'No image available',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    final NoteController noteController = Get.find<NoteController>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Note?'),
        content: Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              noteController.deleteNote(note.id!);
              Navigator.pop(context);
              Get.back();
              Get.snackbar('Deleted', 'Note has been deleted');
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}