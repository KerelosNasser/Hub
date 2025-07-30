import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SpeechService extends GetxService {
  late stt.SpeechToText _speechToText;
  late FlutterTts _flutterTts;
  
  final RxBool isListening = false.obs;
  final RxBool isSpeaking = false.obs;
  final RxString recognizedText = ''.obs;
  final RxBool isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSpeechServices();
  }

  Future<void> _initializeSpeechServices() async {
    await _initializeSpeechToText();
    await _initializeTextToSpeech();
  }

  Future<void> _initializeSpeechToText() async {
    _speechToText = stt.SpeechToText();
    
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      Fluttertoast.showToast(
        msg: "Microphone permission is required for speech recognition",
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    // Initialize speech to text
    final available = await _speechToText.initialize(
      onStatus: (status) {
        debugPrint('Speech recognition status: $status');
      },
      onError: (error) {
        debugPrint('Speech recognition error: $error');
        isListening.value = false;
        Fluttertoast.showToast(
          msg: "Speech recognition error: ${error.errorMsg}",
          toastLength: Toast.LENGTH_SHORT,
        );
      },
    );

    if (available) {
      isInitialized.value = true;
      // Get available locales and set to English
      var locales = await _speechToText.locales();
      var englishLocale = locales.firstWhereOrNull(
        (locale) => locale.localeId.startsWith('en'),
      );
      if (englishLocale != null) {
        debugPrint('Using English locale: ${englishLocale.localeId}');
      }
    } else {
      Fluttertoast.showToast(
        msg: "Speech recognition not available on this device",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  Future<void> _initializeTextToSpeech() async {
    _flutterTts = FlutterTts();
    
    // Configure TTS settings
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5); // Natural speed
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    // Set completion handler
    _flutterTts.setCompletionHandler(() {
      isSpeaking.value = false;
    });

    // Set error handler
    _flutterTts.setErrorHandler((msg) {
      isSpeaking.value = false;
      debugPrint('TTS Error: $msg');
    });

    // Get available voices and set English voice
    List<dynamic> voices = await _flutterTts.getVoices;
    var englishVoices = voices.where((voice) => 
      voice['locale']?.toString().startsWith('en') ?? false
    ).toList();
    
    if (englishVoices.isNotEmpty) {
      // Prefer US English voice
      var usVoice = englishVoices.firstWhereOrNull(
        (voice) => voice['locale']?.toString().contains('US') ?? false
      );
      if (usVoice != null) {
        await _flutterTts.setVoice({
          "name": usVoice['name'],
          "locale": usVoice['locale']
        });
      }
    }
  }

  Future<void> startListening({
    required Function(String) onResult,
    Function? onListeningStarted,
  }) async {
    if (!isInitialized.value) {
      await _initializeSpeechToText();
      if (!isInitialized.value) {
        Fluttertoast.showToast(
          msg: "Speech recognition not initialized",
          toastLength: Toast.LENGTH_SHORT,
        );
        return;
      }
    }

    if (isListening.value) {
      await stopListening();
      return;
    }

    recognizedText.value = '';
    isListening.value = true;
    
    if (onListeningStarted != null) {
      onListeningStarted();
    }

    await _speechToText.listen(
      onResult: (result) {
        recognizedText.value = result.recognizedWords;
        if (result.finalResult) {
          isListening.value = false;
          onResult(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
    isListening.value = false;
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    
    if (isSpeaking.value) {
      await stopSpeaking();
    }

    isSpeaking.value = true;
    await _flutterTts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    isSpeaking.value = false;
  }

  @override
  void onClose() {
    stopListening();
    stopSpeaking();
    super.onClose();
  }
}
