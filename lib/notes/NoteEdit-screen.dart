import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../todo/todoComponents/addTask/CustomTextFormField.dart';
import 'controller.dart';
import 'drawing-canva.dart';
import 'note_model.dart';

class NoteEditScreen extends StatefulWidget {
  final Note? note;
  const NoteEditScreen({super.key, this.note});

  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? _imagePath;
  String? _drawingPath;
  final List<DrawingPoint?> _drawingPoints = [];
  Color _selectedColor = Colors.black;
  double _strokeWidth = 3;
  ui.Image? _loadedDrawing;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _descController.text = widget.note!.description;
      _imagePath = widget.note!.imagePath;
      _drawingPath = widget.note!.drawingPath;
      if (_drawingPath != null) {
        _loadExistingDrawing();
      }
    }
  }

  Future<void> _loadExistingDrawing() async {
    if (_drawingPath != null) {
      final File drawingFile = File(_drawingPath!);
      if (await drawingFile.exists()) {
        final Uint8List bytes = await drawingFile.readAsBytes();
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo fi = await codec.getNextFrame();
        setState(() {
          _loadedDrawing = fi.image;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  Future<void> _saveDrawing() async {
    if (_drawingPoints.isEmpty && _loadedDrawing == null) return;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = Color(0xffedf3ff)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.largest, paint);

    // Draw the loaded image if it exists
    if (_loadedDrawing != null) {
      canvas.drawImage(_loadedDrawing!, Offset.zero, Paint());
    }

    // Draw new points
    for (int i = 0; i < _drawingPoints.length - 1; i++) {
      if (_drawingPoints[i] != null && _drawingPoints[i + 1] != null) {
        canvas.drawLine(
          _drawingPoints[i]!.point,
          _drawingPoints[i + 1]!.point,
          _drawingPoints[i]!.paint,
        );
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(300, 300);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(buffer);

    setState(() => _drawingPath = file.path);
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty) return;

    final note = Note(
      id: widget.note?.id,
      title: _titleController.text,
      description: _descController.text,
      imagePath: _imagePath,
      drawingPath: _drawingPath,
      createdAt: widget.note?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final controller = Get.find<NoteController>();
    if (widget.note == null) {
      await controller.addNote(note);
    } else {
      await controller.updateNote(note);
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade800,
      appBar: AppBar(
        backgroundColor: Colors.pink.shade800,
        title: Text(
          widget.note == null ? 'New Note' : 'Edit Note',
          style: TextStyle(color: Color(0xffedf3ff), fontSize: 24, fontWeight: FontWeight.bold),
        ),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Color(0xffedf3ff)),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextFormField(
              controller: _titleController,
              label: 'Title',
              maxLines: 1,
            ),
             SizedBox(height: context.mediaQuerySize.height *.02),
            CustomTextFormField(
              controller: _descController,
              maxLines: 5,
              label: 'Description',
            ),
             SizedBox(height: context.mediaQuerySize.height *.02),
            Row(
              children: [
                Expanded(
                  child: _imagePath != null
                      ? Image.file(File(_imagePath!))
                      : Center(
                    child: Container(
                      height: context.mediaQuerySize.height *.2,
                      width: context.mediaQuerySize.width *.6,
                      decoration: BoxDecoration(
                        color: Color(0xffedf3ff),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.pinkAccent,
                          strokeAlign: 1,
                        ),
                      ),
                      child: Center(child: Text('No image yet', textAlign: TextAlign.center)),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.photo_camera_back_outlined, color: Colors.white),
                  onPressed: _pickImage,
                ),
              ],
            ),
            SizedBox(height: context.mediaQuerySize.height *0.02),
            Container(
              height: context.mediaQuerySize.height * 0.7,
              width: context.mediaQuerySize.width,
              decoration: BoxDecoration(
                color: Color(0xffedf3ff),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _drawingPoints.add(
                      DrawingPoint(
                        point: details.localPosition,
                        paint: Paint()
                          ..color = _selectedColor
                          ..strokeWidth = _strokeWidth
                          ..strokeCap = StrokeCap.round,
                      ),
                    );
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _drawingPoints.add(
                      DrawingPoint(
                        point: details.localPosition,
                        paint: Paint()
                          ..color = _selectedColor
                          ..strokeWidth = _strokeWidth
                          ..strokeCap = StrokeCap.round,
                      ),
                    );
                  });
                },
                onPanEnd: (_) {
                  _drawingPoints.add(null);
                  _saveDrawing();
                },
                child: CustomPaint(
                  size: Size.infinite,
                  painter: DrawingPainter(_drawingPoints, backgroundImage: _loadedDrawing),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Color(0xffedf3ff)),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    elevation: WidgetStateProperty.all(5),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Pick a color', style: TextStyle(color: Colors.white)),
                        backgroundColor: Color(0x3f000000),
                        content: ColorPicker(
                          pickerColor: _selectedColor,
                          onColorChanged: (color) {
                            setState(() => _selectedColor = color);
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Done', style: TextStyle(color: Color(0xffedf3ff))),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Color', style: TextStyle(color: Colors.pink)),
                ),
                Slider(
                  activeColor: Colors.pink.shade500,
                  value: _strokeWidth,
                  min: 1,
                  max: 24,
                  onChanged: (value) {
                    setState(() => _strokeWidth = value);
                  },
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Color(0xffedf3ff)),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    elevation: WidgetStateProperty.all(5),
                  ),
                  onPressed: () {
                    setState(() {
                      _drawingPoints.clear();
                      _loadedDrawing = null;
                      _drawingPath = null;
                    });
                  },
                  child: const Text('Clear', style: TextStyle(color: Colors.pink)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}