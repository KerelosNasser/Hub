import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../controllers/expense_controller.dart';

class OCRService {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<ExpenseData?> scanReceipt() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image == null) return null;

      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // Parse the recognized text to extract expense information
      return _parseReceiptText(recognizedText.text);
    } catch (e) {
      print('Error scanning receipt: $e');
      return null;
    }
  }

  ExpenseData? _parseReceiptText(String text) {
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    if (lines.isEmpty) return null;

    // Extract amount using regex
    final amountRegex = RegExp(r'\$?(\d+\.?\d*)');
    double? amount;
    String? title;
    String description = '';

    // Look for total amount (usually at the bottom)
    for (int i = lines.length - 1; i >= 0; i--) {
      final line = lines[i].toLowerCase();
      if (line.contains('total') || line.contains('amount') || line.contains('sum')) {
        final match = amountRegex.firstMatch(lines[i]);
        if (match != null) {
          amount = double.tryParse(match.group(1) ?? '');
          if (amount != null) break;
        }
      }
    }

    // If no total found, look for any amount
    if (amount == null) {
      for (final line in lines) {
        final match = amountRegex.firstMatch(line);
        if (match != null) {
          final potentialAmount = double.tryParse(match.group(1) ?? '');
          if (potentialAmount != null && potentialAmount > 0) {
            amount = potentialAmount;
            break;
          }
        }
      }
    }

    // Extract store name/title (usually first few lines)
    if (lines.isNotEmpty) {
      title = lines[0].trim();
      // If title looks like a store name, use it; otherwise use generic title
      if (title.length < 3 || title.contains(RegExp(r'^\d+$'))) {
        title = 'Receipt Expense';
      }
    }

    // Create description from relevant lines
    final relevantLines = lines.take(3).where((line) => 
        !line.toLowerCase().contains('receipt') &&
        !line.toLowerCase().contains('thank you') &&
        line.length > 2
    ).toList();
    
    description = relevantLines.join(' • ');

    return ExpenseData(
      title: title ?? 'Receipt Expense',
      description: description,
      amount: amount ?? 0.0,
      category: '', // Will be filled by AI categorization
      date: DateTime.now(),
    );
  }

  void dispose() {
    _textRecognizer.close();
  }
}