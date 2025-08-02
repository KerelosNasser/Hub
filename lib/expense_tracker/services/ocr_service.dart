import 'dart:math' as Math;

import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/expense_controller.dart';

class OCRService {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<ExpenseData?> scanReceipt() async {
    try {
      // Request camera permission
      final permission = await Permission.camera.request();
      if (permission != PermissionStatus.granted) {
        throw Exception('Camera permission denied');
      }

      // Pick image from camera
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) {
        return null; // User cancelled
      }

      // Process the image
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // Parse the recognized text to extract expense information
      return _parseReceiptText(recognizedText.text);
    } catch (e) {
      print('Error scanning receipt: $e');
      rethrow; // Re-throw to let the caller handle the error
    }
  }

  Future<ExpenseData?> pickImageFromGallery() async {
    try {
      // Request photo library permission
      final permission = await Permission.photos.request();
      if (permission != PermissionStatus.granted) {
        throw Exception('Photo library permission denied');
      }

      // Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) {
        return null; // User cancelled
      }

      // Process the image
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // Parse the recognized text to extract expense information
      return _parseReceiptText(recognizedText.text);
    } catch (e) {
      print('Error picking image from gallery: $e');
      rethrow;
    }
  }

  ExpenseData? _parseReceiptText(String text) {
    if (text.trim().isEmpty) return null;

    final lines = text.split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.trim())
        .toList();
    
    if (lines.isEmpty) return null;

    // Enhanced amount extraction with multiple patterns
    final amountPatterns = [
      RegExp(r'total[:\s]*\$?(\d+\.?\d*)', caseSensitive: false),
      RegExp(r'amount[:\s]*\$?(\d+\.?\d*)', caseSensitive: false),
      RegExp(r'sum[:\s]*\$?(\d+\.?\d*)', caseSensitive: false),
      RegExp(r'subtotal[:\s]*\$?(\d+\.?\d*)',caseSensitive: false),
      RegExp(r'\$(\d+\.?\d*)'), // Any dollar amount
      RegExp(r'(\d+\.\d{2})'), // Any decimal with 2 places
    ];

    double? amount;
    String? title;
    String description = '';
    List<String> potentialAmounts = [];

    // Extract all potential amounts
    for (final line in lines) {
      for (final pattern in amountPatterns) {
        final matches = pattern.allMatches(line);
        for (final match in matches) {
          final amountStr = match.group(1);
          if (amountStr != null) {
            final potentialAmount = double.tryParse(amountStr);
            if (potentialAmount != null && potentialAmount > 0) {
              potentialAmounts.add('${potentialAmount.toStringAsFixed(2)} (from: ${line.trim()})');
              // Prioritize amounts with keywords
              if (amount == null || line.toLowerCase().contains('total') || 
                  line.toLowerCase().contains('amount')) {
                amount = potentialAmount;
              }
            }
          }
        }
      }
    }

    // If no amount found with keywords, use the largest reasonable amount
    if (amount == null && potentialAmounts.isNotEmpty) {
      double maxAmount = 0;
      for (final line in lines) {
        for (final pattern in amountPatterns) {
          final match = pattern.firstMatch(line);
          if (match != null) {
            final amountStr = match.group(1);
            if (amountStr != null) {
              final potentialAmount = double.tryParse(amountStr);
              if (potentialAmount != null && potentialAmount > maxAmount && potentialAmount < 10000) {
                maxAmount = potentialAmount;
              }
            }
          }
        }
      }
      if (maxAmount > 0) amount = maxAmount;
    }

    // Enhanced store name/title extraction
    if (lines.isNotEmpty) {
      // Look for common store patterns
      for (int i = 0; i < Math.min(3, lines.length); i++) {
        final line = lines[i].trim();
        
        // Skip obvious non-store names
        if (_isLikelyStoreName(line)) {
          title = _cleanStoreName(line);
          break;
        }
      }
      
      // Fallback to first meaningful line
      if (title == null) {
        for (final line in lines.take(3)) {
          if (line.length >= 3 && 
              !RegExp(r'^\d+$').hasMatch(line) &&
              !line.toLowerCase().contains('receipt') &&
              !line.toLowerCase().contains('transaction')) {
            title = _cleanStoreName(line);
            break;
          }
        }
      }
    }

    // Create description from relevant information
    final relevantLines = lines.take(5).where((line) => 
        !line.toLowerCase().contains('receipt') &&
        !line.toLowerCase().contains('thank you') &&
        !line.toLowerCase().contains('visit us') &&
        !line.toLowerCase().contains('www.') &&
        line.length > 2 &&
        line != title
    ).take(3).toList();
    
    description = relevantLines.join(' • ');
    
    // Add debugging information if no amount found
    if (amount == null && potentialAmounts.isNotEmpty) {
      description += '\n\nPotential amounts found:\n${potentialAmounts.join('\n')}';
    }

    return ExpenseData(
      title: title ?? 'Receipt Expense',
      description: description,
      amount: amount ?? 0.0,
      category: _predictCategory(title ?? '', description),
      date: DateTime.now(),
    );
  }

  bool _isLikelyStoreName(String line) {
    final lowerLine = line.toLowerCase();
    
    // Common store indicators
    final storeIndicators = [
      'store', 'shop', 'market', 'cafe', 'restaurant', 'pharmacy', 
      'mall', 'center', 'inc', 'llc', 'ltd', 'corp', 'company',
      'gas', 'fuel', 'station', 'hotel', 'motel'
    ];
    
    // Check if line contains store indicators
    for (final indicator in storeIndicators) {
      if (lowerLine.contains(indicator)) return true;
    }
    
    // Check if it looks like a business name (has capital letters, reasonable length)
    return line.length >= 3 && 
           line.length <= 50 &&
           RegExp(r'[A-Z]').hasMatch(line) &&
           !RegExp(r'^\d+\.?\d*$').hasMatch(line);
  }

  String _cleanStoreName(String name) {
    // Remove common prefixes/suffixes and clean up
    String cleaned = name
        .replaceAll(RegExp(r'#\d+'), '') // Remove receipt numbers
        .replaceAll(RegExp(r'\*+'), '') // Remove asterisks
        .replaceAll(RegExp(r'-+'), '') // Remove dashes
        .trim();
    
    // Capitalize properly
    return cleaned.split(' ')
        .map((word) => word.isNotEmpty 
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : word)
        .join(' ')
        .trim();
  }

  String _predictCategory(String title, String description) {
    final text = '${title.toLowerCase()} ${description.toLowerCase()}';
    
    // Category prediction based on keywords
    final categoryMap = {
      'Food & Dining': ['restaurant', 'cafe', 'food', 'dining', 'pizza', 'burger', 'coffee', 'bar', 'lunch', 'dinner'],
      'Groceries': ['grocery', 'supermarket', 'market', 'walmart', 'target', 'kroger', 'safeway', 'produce'],
      'Gas & Fuel': ['gas', 'fuel', 'station', 'shell', 'exxon', 'chevron', 'bp', 'mobil'],
      'Shopping': ['store', 'shop', 'mall', 'amazon', 'ebay', 'clothing', 'electronics'],
      'Healthcare': ['pharmacy', 'hospital', 'clinic', 'doctor', 'medical', 'cvs', 'walgreens'],
      'Transportation': ['uber', 'lyft', 'taxi', 'bus', 'train', 'parking', 'toll'],
      'Entertainment': ['movie', 'cinema', 'theater', 'game', 'park', 'museum'],
      'Utilities': ['electric', 'water', 'internet', 'phone', 'cable'],
    };
    
    for (final category in categoryMap.keys) {
      for (final keyword in categoryMap[category]!) {
        if (text.contains(keyword)) {
          return category;
        }
      }
    }
    
    return 'Other'; // Default category
  }

  void dispose() {
    _textRecognizer.close();
  }
}