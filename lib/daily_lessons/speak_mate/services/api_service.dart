import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';

class ApiService extends GetxService {
  static const String defaultApiUrl = 'http://localhost:5000/chat';
  static const String groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  // You'll need to get a free API key from https://console.groq.com/keys
  // For now, using a placeholder - replace this with your actual key
  static const String groqApiKey = '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';
  
  final String apiUrl;
  bool _useCloudFallback = false;
  
  ApiService({String? customUrl}) : apiUrl = customUrl ?? defaultApiUrl;

  Future<String> sendChatMessage(String message) async {
    try {
      // Check network connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        throw Exception('No internet connection');
      }

      // Try local Ollama server first
      if (!_useCloudFallback) {
        try {
          final localResponse = await _sendToLocalServer(message);
          return localResponse;
        } catch (localError) {
          print('Local server failed, switching to cloud: $localError');
          _useCloudFallback = true;
          
          Fluttertoast.showToast(
            msg: "Switching to cloud AI service...",
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      }
      
      // Use cloud service as fallback
      return await _sendToCloudService(message);
    } catch (e) {
      // Handle different types of errors
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection refused')) {
        Fluttertoast.showToast(
          msg: "Both local and cloud AI services unavailable.",
          toastLength: Toast.LENGTH_LONG,
        );
        return _getMockResponse(message);
      } else if (e.toString().contains('timeout')) {
        return "Sorry, the AI server took too long to respond. Please try again.";
      } else if (e.toString().contains('No internet connection')) {
        return "No internet connection detected. Please check your network settings.";
      } else {
        return "An error occurred: ${e.toString()}";
      }
    }
  }
  
  Future<String> _sendToLocalServer(String message) async {
    final uri = Uri.parse(apiUrl);
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'message': message});

    final response = await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 5)); // Shorter timeout for local

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['response'] ?? 'I didn\'t quite understand that. Could you try again?';
    } else {
      throw Exception('Local server error: ${response.statusCode}');
    }
  }
  
  Future<String> _sendToCloudService(String message) async {
    // Check if API key is configured
    if (groqApiKey == 'YOUR_GROQ_API_KEY_HERE') {
      return "Cloud service not configured. Please add your Groq API key in the settings.";
    }
    
    final uri = Uri.parse(groqApiUrl);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $groqApiKey',
    };
    
    final body = json.encode({
      'model': 'llama-3.2-3b-preview', // Fast model suitable for chat
      'messages': [
        {
          'role': 'system',
          'content': _getSystemPrompt(),
        },
        {
          'role': 'user',
          'content': message,
        }
      ],
      'temperature': 0.7,
      'max_tokens': 500,
      'stream': false,
    });

    try {
      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final content = responseData['choices'][0]['message']['content'];
        return content ?? 'I didn\'t quite understand that. Could you try again?';
      } else if (response.statusCode == 401) {
        return "API key invalid. Please check your Groq API key.";
      } else if (response.statusCode == 429) {
        return "Rate limit reached. Please try again in a moment.";
      } else {
        throw Exception('Cloud service error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Cloud service failed: $e');
    }
  }
  
  String _getSystemPrompt() {
    return '''You are an English language learning assistant called SpeakMate. Your role is to:
1. Help users practice conversational English
2. Correct grammar mistakes gently and explain why
3. Suggest better ways to express ideas in English
4. Provide vocabulary tips and common phrases
5. Be encouraging and supportive
6. Keep responses concise and easy to understand
7. Use simple language appropriate for English learners

Respond in a friendly, conversational tone. If the user makes grammar mistakes, correct them naturally within your response.''';
  }

  // Mock responses for testing when API is not available
  String _getMockResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return "Hello! I'm your English learning assistant. How can I help you practice English today?";
    } else if (lowerMessage.contains('how are you')) {
      return "I'm doing great, thank you for asking! How about you? How has your day been so far?";
    } else if (lowerMessage.contains('help')) {
      return "I'm here to help you practice English! You can ask me questions, practice conversations, or ask for grammar tips. What would you like to work on?";
    } else if (lowerMessage.contains('grammar')) {
      return "Grammar is important! Some common areas to focus on are verb tenses, articles (a, an, the), and subject-verb agreement. Which topic interests you?";
    } else if (lowerMessage.contains('bye') || lowerMessage.contains('goodbye')) {
      return "Goodbye! Keep practicing, and remember: the more you speak, the better you'll become!";
    } else {
      return "That's interesting! In English, we might say it like this: '$message'. Would you like to practice more phrases?";
    }
  }

  // Method to update API URL if needed
  void updateApiUrl(String newUrl) {
    // This would need to be implemented with proper state management
    // For now, it's a placeholder
  }
  
  // Method to check if using cloud service
  bool get isUsingCloud => _useCloudFallback;
  
  // Method to manually switch between local and cloud
  void toggleServiceMode() {
    _useCloudFallback = !_useCloudFallback;
    Fluttertoast.showToast(
      msg: _useCloudFallback ? "Using cloud AI service" : "Using local AI service",
      toastLength: Toast.LENGTH_SHORT,
    );
  }
  
  // Method to test local server availability
  Future<bool> isLocalServerAvailable() async {
    try {
      final uri = Uri.parse('http://localhost:5000/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
