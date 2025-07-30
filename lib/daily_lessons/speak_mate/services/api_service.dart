import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiService {
  static const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  // IMPORTANT: It's recommended to load this from environment variables
  // or a secure configuration file, not hardcoded.
  static const String _groqApiKey = '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';

  Future<String> sendChatMessage(String message) async {
    // 1. Check for API Key
    if (_groqApiKey.isEmpty) {
      const errorMsg = 'Groq API key is not configured. Please set it up.';
      Fluttertoast.showToast(msg: errorMsg);
      return errorMsg;
    }

    // 2. Check Network Connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      const errorMsg = 'No internet connection. Please check your network.';
      Fluttertoast.showToast(msg: errorMsg);
      return errorMsg;
    }

    // 3. Prepare the API Request
    final uri = Uri.parse(_groqApiUrl);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_groqApiKey',
    };
    
    final body = json.encode({
      'model': 'llama-3.3-70b-versatile', // A capable and fast model
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
    });

    // 4. Send the Request and Handle Response
    try {
      final response = await http.post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final content = responseData['choices'][0]['message']['content'];
        return content ?? 'Sorry, I received an empty response. Please try again.';
      } else {
        // Handle specific API errors
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Unknown API error';
        Fluttertoast.showToast(msg: 'API Error: ${response.statusCode} - $errorMessage');
        return 'Sorry, I couldn\'t get a response. $errorMessage';
      }
    } on TimeoutException {
      const errorMsg = 'The request timed out. Please try again.';
      Fluttertoast.showToast(msg: errorMsg);
      return errorMsg;
    } catch (e) {
      final errorMsg = 'An unexpected error occurred: ${e.toString()}';
      Fluttertoast.showToast(msg: errorMsg);
      return errorMsg;
    }
  }

  String _getSystemPrompt() {
    return '''You are SpeakMate, a friendly and encouraging English language learning assistant.
Your main goals are:
1.  **Engage in Natural Conversation**: Chat with the user to help them practice speaking.
2.  **Correct Gently**: If you spot a mistake, don't just point it out. Instead, rephrase their sentence correctly as part of your natural reply. For example, if the user says "I go to store yesterday," you could say, "Oh, you went to the store yesterday? What did you buy?"
3.  **Keep it Simple & Clear**: Use language that is easy for an English learner to understand.
4.  **Be Supportive**: Always be positive and encouraging!''';
  }
}
