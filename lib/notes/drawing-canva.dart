import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> drawingPoints;
  final ui.Image? backgroundImage;  // Explicitly use ui.Image

  DrawingPainter(this.drawingPoints, {this.backgroundImage});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    final paint = Paint()
      ..color = Color(0xffedf3ff)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);

    // Draw loaded image if exists
    if (backgroundImage != null) {
      canvas.drawImage(backgroundImage!, Offset.zero, Paint());
    }

    // Draw new points
    for (int i = 0; i < drawingPoints.length - 1; i++) {
      if (drawingPoints[i] != null && drawingPoints[i + 1] != null) {
        canvas.drawLine(
          drawingPoints[i]!.point,
          drawingPoints[i + 1]!.point,
          drawingPoints[i]!.paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DrawingPoint {
  final Offset point;
  final Paint paint;

  DrawingPoint({required this.point, required this.paint});
}