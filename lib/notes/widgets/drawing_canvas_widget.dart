import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class DrawingCanvasWidget extends StatefulWidget {
  final Function(String) onSave;
  final String? initialDrawingPath;

  const DrawingCanvasWidget({
    super.key,
    required this.onSave,
    this.initialDrawingPath,
  });

  @override
  _DrawingCanvasWidgetState createState() => _DrawingCanvasWidgetState();
}

class _DrawingCanvasWidgetState extends State<DrawingCanvasWidget> {
  final List<DrawnLine> lines = [];
  DrawnLine? currentLine;
  Color selectedColor = Colors.black;
  double selectedWidth = 5.0;
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background with some transparency
          Container(
            color: Colors.black.withOpacity(0.7),
          ),

          // Main drawing area
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 80),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Show existing drawing if provided
                  if (widget.initialDrawingPath != null &&
                      widget.initialDrawingPath!.isNotEmpty)
                    Positioned.fill(
                      child: Image.file(
                        File(widget.initialDrawingPath!),
                        fit: BoxFit.contain,
                        opacity: AlwaysStoppedAnimation(
                            0.2), // Show as faded background
                      ),
                    ),

                  // Actual drawing canvas
                  GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: RepaintBoundary(
                      key: _repaintBoundaryKey,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.transparent,
                        child: CustomPaint(
                          painter: DrawingPainter(lines: lines),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom toolbar
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Color picker
                  _buildColorButton(Colors.black),
                  _buildColorButton(Colors.red),
                  _buildColorButton(Colors.blue),
                  _buildColorButton(Colors.green),
                  _buildColorButton(Colors.yellow),

                  // Divider
                  Container(
                    height: 30,
                    width: 1,
                    color: Colors.grey.withOpacity(0.5),
                  ),

                  // Brush size slider
                  Expanded(
                    child: Slider(
                      value: selectedWidth,
                      min: 1.0,
                      max: 20.0,
                      activeColor: selectedColor,
                      onChanged: (value) {
                        setState(() {
                          selectedWidth = value;
                        });
                      },
                    ),
                  ),

                  // Clear button
                  IconButton(
                    icon:
                        Icon(Icons.delete_outline, color: Colors.red.shade300),
                    onPressed: _clearCanvas,
                  ),
                ],
              ),
            ),
          ),

          // Top close and save buttons
          Positioned(
            top: 30,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.save),
                  label: Text('Save Drawing'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade800,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _saveDrawing,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    bool isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.grey.shade500 : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset point = renderBox.globalToLocal(details.globalPosition);

    // Adjust for padding and margin
    final canvasMargin = EdgeInsets.symmetric(horizontal: 20, vertical: 80);
    point = point.translate(-canvasMargin.left, -canvasMargin.top);

    setState(() {
      currentLine = DrawnLine(
        points: [point],
        color: selectedColor,
        width: selectedWidth,
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (currentLine == null) return;

    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset point = renderBox.globalToLocal(details.globalPosition);

    // Adjust for padding and margin
    final canvasMargin = EdgeInsets.symmetric(horizontal: 20, vertical: 80);
    point = point.translate(-canvasMargin.left, -canvasMargin.top);

    setState(() {
      currentLine!.points.add(point);
      lines.add(currentLine!);
      currentLine = currentLine!.copyWith(points: [...currentLine!.points]);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      currentLine = null;
    });
  }

  void _clearCanvas() {
    setState(() {
      lines.clear();
    });
  }

  Future<void> _saveDrawing() async {
    try {
      // Create a RenderRepaintBoundary from our CustomPaint using the GlobalKey
      RenderRepaintBoundary boundary =
          _repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // Convert it to an image
      var image = await boundary.toImage();
      var byteData = await image.toByteData(format: ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();

      // Get a temporary directory and create a file
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${directory.path}/drawing_$timestamp.png';

      File file = File(path);
      await file.writeAsBytes(pngBytes);

      // Call the callback with the file path
      widget.onSave(path);

      // Close the dialog
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving drawing: $e')),
      );
    }
  }
}

class DrawnLine {
  final List<Offset> points;
  final Color color;
  final double width;

  DrawnLine({
    required this.points,
    required this.color,
    required this.width,
  });

  DrawnLine copyWith({
    List<Offset>? points,
    Color? color,
    double? width,
  }) {
    return DrawnLine(
      points: points ?? this.points,
      color: color ?? this.color,
      width: width ?? this.width,
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;

  DrawingPainter({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    for (DrawnLine line in lines) {
      final paint = Paint()
        ..color = line.color
        ..strokeWidth = line.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < line.points.length - 1; i++) {
        canvas.drawLine(line.points[i], line.points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
