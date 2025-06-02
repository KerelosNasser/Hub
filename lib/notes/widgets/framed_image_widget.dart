import 'dart:io';
import 'package:flutter/material.dart';

class FramedImageWidget extends StatelessWidget {
  final String imagePath;
  final String frameStyle;
  final double width;
  final double height;
  final BoxFit fit;
  final bool isAsset;

  const FramedImageWidget({
    Key? key,
    required this.imagePath,
    this.frameStyle = 'minimal',
    this.width = double.infinity,
    this.height = 200,
    this.fit = BoxFit.cover,
    this.isAsset = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: _getMargin(),
      decoration: BoxDecoration(
        color: _getFrameColor(),
        borderRadius: _getBorderRadius(),
        boxShadow: _getBoxShadow(),
        border: _getBorder(),
      ),
      child: Padding(
        padding: _getImagePadding(),
        child: ClipRRect(
          borderRadius: _getImageBorderRadius(),
          child: isAsset
              ? Image.asset(
                  imagePath,
                  fit: fit,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey.shade400,
                        size: 40,
                      ),
                    );
                  },
                )
              : Image.file(
                  File(imagePath),
                  fit: fit,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey.shade400,
                        size: 40,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  EdgeInsets _getMargin() {
    switch (frameStyle) {
      case 'modern':
        return EdgeInsets.all(4);
      case 'vintage':
        return EdgeInsets.all(8);
      case 'polaroid':
        return EdgeInsets.all(6);
      case 'minimal':
        return EdgeInsets.zero;
      case 'classic':
        return EdgeInsets.all(10);
      default:
        return EdgeInsets.zero;
    }
  }

  EdgeInsets _getImagePadding() {
    switch (frameStyle) {
      case 'modern':
        return EdgeInsets.all(1);
      case 'vintage':
        return EdgeInsets.all(8);
      case 'polaroid':
        return EdgeInsets.only(bottom: 40, left: 10, right: 10, top: 10);
      case 'minimal':
        return EdgeInsets.zero;
      case 'classic':
        return EdgeInsets.all(5);
      default:
        return EdgeInsets.zero;
    }
  }

  BorderRadius _getBorderRadius() {
    switch (frameStyle) {
      case 'modern':
        return BorderRadius.circular(12);
      case 'vintage':
        return BorderRadius.circular(2);
      case 'polaroid':
        return BorderRadius.circular(2);
      case 'minimal':
        return BorderRadius.circular(8);
      case 'classic':
        return BorderRadius.circular(0);
      default:
        return BorderRadius.circular(8);
    }
  }

  BorderRadius _getImageBorderRadius() {
    switch (frameStyle) {
      case 'modern':
        return BorderRadius.circular(10);
      case 'vintage':
        return BorderRadius.circular(0);
      case 'polaroid':
        return BorderRadius.circular(0);
      case 'minimal':
        return BorderRadius.circular(8);
      case 'classic':
        return BorderRadius.circular(0);
      default:
        return BorderRadius.circular(8);
    }
  }

  Color _getFrameColor() {
    switch (frameStyle) {
      case 'modern':
        return Colors.white;
      case 'vintage':
        return Color(0xFFECE6D6);
      case 'polaroid':
        return Colors.white;
      case 'minimal':
        return Colors.transparent;
      case 'classic':
        return Color(0xFF372E29);
      default:
        return Colors.transparent;
    }
  }

  Border? _getBorder() {
    switch (frameStyle) {
      case 'modern':
        return Border.all(color: Colors.grey.shade200, width: 1);
      case 'vintage':
        return Border.all(color: Colors.brown.shade200, width: 1);
      case 'polaroid':
        return Border.all(color: Colors.grey.shade300, width: 1);
      case 'minimal':
        return null;
      case 'classic':
        return Border.all(color: Colors.black, width: 2);
      default:
        return null;
    }
  }

  List<BoxShadow>? _getBoxShadow() {
    switch (frameStyle) {
      case 'modern':
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ];
      case 'vintage':
        return [
          BoxShadow(
            color: Colors.brown.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(2, 2),
          ),
        ];
      case 'polaroid':
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ];
      case 'minimal':
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ];
      case 'classic':
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(3, 3),
          ),
        ];
      default:
        return null;
    }
  }
}
