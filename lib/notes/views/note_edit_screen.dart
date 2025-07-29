import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../controllers/note_controller.dart';
import '../models/note_model.dart';
import '../widgets/drawing_canvas_widget.dart';

class NoteEditScreen extends StatefulWidget {
  final int? noteId;

  const NoteEditScreen({super.key, this.noteId});

  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final NoteController _noteController = Get.find<NoteController>();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  DateTime _selectedDate = DateTime.now();
  List<String> _imagePaths = [];
  String? _drawingPath;
  String _selectedColor = '#FFE91E63'; // Default pink color
  bool _isLoading = false;
  bool _isNewNote = true;

  @override
  void initState() {
    super.initState();
    _loadNoteData();
  }

  Future<void> _loadNoteData() async {
    if (widget.noteId != null) {
      setState(() {
        _isLoading = true;
        _isNewNote = false;
      });

      try {
        final note = await _noteController.getNoteById(widget.noteId!);
        if (note != null) {
          _titleController.text = note.title;
          _descriptionController.text = note.description;
          _selectedDate = note.createdAt;
          _imagePaths = List<String>.from(note.imagePaths);
          _drawingPath = note.drawingPath;
          _selectedColor = note.color;
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to load note: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade800,
      appBar: AppBar(
        title: Text(
          _isNewNote ? 'New Note' : 'Edit Note',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.pink.shade800,
        elevation: 0,
        actions: [
          // Color picker button
          IconButton(
            icon: Icon(Icons.color_lens),
            onPressed: _showColorPicker,
            tooltip: 'Change note color',
            color: Colors.white,
          ),
          // Save button
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _saveNote,
            tooltip: 'Save note',
            color: Colors.white,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title section
                    _buildTitleSection(),
                    SizedBox(height: 16),

                    // Date section
                    _buildDateSection(),
                    SizedBox(height: 16),

                    // Description section
                    _buildDescriptionSection(),
                    SizedBox(height: 24),

                    // Images section
                    _buildImagesSection(),
                    SizedBox(height: 24),

                    // Drawing section
                    _buildDrawingSection(),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  // Replace _buildTitleSection() with:
  Widget _buildTitleSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: TextFormField(
        controller: _titleController,
        decoration: InputDecoration(
          labelText: 'Title',
          labelStyle: TextStyle(color: Colors.black87),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          icon: Icon(Icons.title, color: _getColorFromHex(_selectedColor)),
        ),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.amberAccent,
        ),
        maxLines: 2,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a title';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: InkWell(
        onTap: _selectDate,
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: _getColorFromHex(_selectedColor)),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Replace _buildDescriptionSection() with:
  Widget _buildDescriptionSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: TextFormField(
        controller: _descriptionController,
        decoration: InputDecoration(
          labelText: 'Description',
          labelStyle: TextStyle(color: Colors.black87),
          alignLabelWithHint: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          icon: Icon(Icons.description, color: _getColorFromHex(_selectedColor)),
        ),
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        maxLines: 5,
        minLines: 3,
      ),
    );
  }

  // Replace _buildImagesSection() with:
  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Images',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                if (_imagePaths.length < 9)
                  ElevatedButton.icon(
                    onPressed: _pickImageFromCamera,
                    icon: Icon(Icons.camera_alt, size: 18),
                    label: Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                SizedBox(width: 8),
                if (_imagePaths.length < 9)
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.photo_library, size: 18),
                    label: Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16),
        _imagePaths.isEmpty
            ? _buildEmptyImagesPlaceholder()
            : _buildImageGrid(),
      ],
    );
  }

  // Replace _buildImageCollage() with _buildImageGrid():
  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _imagePaths.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_imagePaths[index]),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Add these new methods:
  Future<void> _pickImageFromCamera() async {
    if (_imagePaths.length >= 9) {
      Get.snackbar('Limit Reached', 'Maximum 9 images allowed');
      return;
    }

    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imagePaths.add(pickedFile.path);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  // Update _buildEmptyImagesPlaceholder():
  Widget _buildEmptyImagesPlaceholder() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_outlined, size: 48, color: Colors.grey.shade600),
            SizedBox(height: 8),
            Text(
              'Add up to 9 images',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCollage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;

          if (_imagePaths.length == 1) {
            // Single image
            return _buildSingleImage(maxWidth, 200);
          } else if (_imagePaths.length == 2) {
            // Two images side by side
            return Row(
              children: [
                Expanded(
                    child: _buildImageTile(_imagePaths[0],
                        onDelete: () => _removeImage(0))),
                SizedBox(width: 8),
                Expanded(
                    child: _buildImageTile(_imagePaths[1],
                        onDelete: () => _removeImage(1))),
              ],
            );
          } else if (_imagePaths.length == 3) {
            // One large, two small
            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildImageTile(_imagePaths[0],
                      onDelete: () => _removeImage(0)),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildImageTile(_imagePaths[1],
                          onDelete: () => _removeImage(1)),
                      SizedBox(height: 8),
                      _buildImageTile(_imagePaths[2],
                          onDelete: () => _removeImage(2)),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // Grid for 4+ images
            return GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                return _buildImageTile(
                  _imagePaths[index],
                  onDelete: () => _removeImage(index),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildSingleImage(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(_imagePaths[0]),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _removeImage(0),
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageTile(String path, {required VoidCallback onDelete}) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Drawing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _openDrawingCanvas,
              icon: Icon(_drawingPath == null ? Icons.brush : Icons.edit),
              label:
                  Text(_drawingPath == null ? 'Add Drawing' : 'Edit Drawing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _drawingPath == null
            ? _buildEmptyDrawingPlaceholder()
            : _buildDrawingPreview(),
      ],
    );
  }

  Widget _buildEmptyDrawingPlaceholder() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.brush,
              size: 48,
              color: Colors.pink.shade600,
            ),
            SizedBox(height: 8),
            Text(
              'No drawing added yet',
              style: TextStyle(
                color: Colors.pink.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawingPreview() {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_drawingPath!),
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              GestureDetector(
                onTap: _openDrawingCanvas,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: _removeDrawing,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _getColorFromHex(_selectedColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePaths.add(image.path);
      });
    }
  }

  void _openDrawingCanvas() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DrawingCanvasWidget(
        initialDrawingPath: _drawingPath,
        onSave: (path) {
          setState(() {
            _drawingPath = path;
          });
        },
      ),
    );
  }

  void _removeDrawing() {
    setState(() {
      _drawingPath = null;
    });
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Note Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _getColorFromHex(_selectedColor),
            onColorChanged: (color) {
              setState(() {
                _selectedColor =
                    '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
              });
            },
            enableAlpha: false,
            pickerAreaHeightPercent: 0.8,
            displayThumbColor: true,
            labelTypes: [ColorLabelType.hex, ColorLabelType.rgb],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();

      final note = Note(
        id: widget.noteId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        createdAt: _isNewNote ? now : _selectedDate,
        updatedAt: now,
        imagePaths: _imagePaths,
        drawingPath: _drawingPath,
        color: _selectedColor,
      );

      if (_isNewNote) {
        await _noteController.addNote(note);
      } else {
        await _noteController.updateNote(note);
      }

      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save note: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
