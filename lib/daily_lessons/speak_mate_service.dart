import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'speak_mate_model.dart';

class SpeakMateService {
  static const String _baseUrl = 'http://192.168.1.100:5000'; // Replace with your local IP
  static const String _chatEndpoint = '/chat';
  
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  late SharedPreferences _prefs;
  
  bool _speechEnabled = false;
  bool _isListening = false;
  
  // Getters
  bool get speechEnabled => _speechEnabled;
  bool get isListening => _isListening;
  
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _initializeSpeech();
    await _initializeTts();
  }
  
  Future<void> _initializeSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (error) => print('Speech recognition error: $error'),
        onStatus: (status) => print('Speech recognition status: $status'),
      );
    } catch (e) {
      print('Failed to initialize speech recognition: $e');
      _speechEnabled = false;
    }
  }
  
  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      
      if (Platform.isAndroid) {
        await _flutterTts.setEngine('com.google.android.tts');
      }
    } catch (e) {
      print('Failed to initialize TTS: $e');
    }
  }
  
  Future<String?> startListening() async {
    if (!_speechEnabled) return null;
    
    String recognizedText = '';
    
    try {
      _isListening = true;
      await _speechToText.listen(
        onResult: (result) {
          recognizedText = result.recognizedWords;
        },
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 3),
        partialResults: false,
        localeId: 'en_US',
        cancelOnError: true,
      );
      
      // Wait for speech to complete
      while (_speechToText.isListening) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      
      _isListening = false;
      return recognizedText.isNotEmpty ? recognizedText : null;
    } catch (e) {
      _isListening = false;
      print('Error during speech recognition: $e');
      return null;
    }
  }
  
  Future<void> stopListening() async {
    await _speechToText.stop();
    _isListening = false;
  }
  
  Future<String?> sendToAI(String message, {bool grammarMode = false}) async {
    try {
      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('No internet connection');
      }
      
      final prompt = grammarMode 
          ? 'Please correct the grammar and provide a better way to say: "$message"'
          : message;
      
      final response = await http.post(
        Uri.parse('$_baseUrl$_chatEndpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': prompt,
          'grammar_mode': grammarMode,
        }),
      ).timeout(Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] as String?;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending to AI: $e');
      // Return mock response for development
      return _getMockResponse(message, grammarMode);
    }
  }
  
  String _getMockResponse(String message, bool grammarMode) {
    if (grammarMode) {
      return 'Here\'s a better way to say that: "$message" - This sounds more natural and grammatically correct!';
    }
    
    final responses = [
      'That\'s interesting! Can you tell me more about that?',
      'Great! Let\'s practice some more English conversation.',
      'I understand. How do you feel about that?',
      'That\'s a good point. What else would you like to discuss?',
      'Excellent! Your English is improving. Keep practicing!',
    ];
    
    return responses[DateTime.now().millisecond % responses.length];
  }
  
  Future<void> speak(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('Error during TTS: $e');
    }
  }
  
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }
  
  // Chat history management
  Future<void> saveChatHistory(List<ChatMessage> messages) async {
    final jsonList = messages.map((msg) => msg.toJson()).toList();
    await _prefs.setString('chat_history', jsonEncode(jsonList));
  }
  
  Future<List<ChatMessage>> loadChatHistory() async {
    final jsonString = _prefs.getString('chat_history');
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => ChatMessage.fromJson(json)).toList();
    } catch (e) {
      print('Error loading chat history: $e');
      return [];
    }
  }
  
  Future<void> clearChatHistory() async {
    await _prefs.remove('chat_history');
  }
  
  // Daily stats management
  Future<void> updateDailyStats() async {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    
    final statsJson = _prefs.getString('daily_stats_$todayKey');
    DailyStats stats;
    
    if (statsJson != null) {
      stats = DailyStats.fromJson(jsonDecode(statsJson));
      stats = DailyStats(
        messageCount: stats.messageCount + 1,
        date: stats.date,
        conversationMinutes: stats.conversationMinutes,
      );
    } else {
      stats = DailyStats(
        messageCount: 1,
        date: today,
      );
    }
    
    await _prefs.setString('daily_stats_$todayKey', jsonEncode(stats.toJson()));
  }
  
  Future<DailyStats?> getTodayStats() async {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    
    final statsJson = _prefs.getString('daily_stats_$todayKey');
    if (statsJson == null) return null;
    
    try {
      return DailyStats.fromJson(jsonDecode(statsJson));
    } catch (e) {
      return null;
    }
  }
}