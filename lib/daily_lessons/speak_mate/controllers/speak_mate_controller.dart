import 'package:get/get.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/speech_service.dart';

class SpeakMateController extends GetxController {
  final ApiService _apiService = Get.put(ApiService());
  final SpeechService _speechService = Get.put(SpeechService());

  final RxList<ChatMessage> chatMessages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;

  void addMessage(ChatMessage message) => chatMessages.add(message);

  Future<void> sendMessage(String message) async {
    addMessage(ChatMessage.user(message));
    isLoading.value = true;

    try {
      final response = await _apiService.sendChatMessage(message);
      addMessage(ChatMessage.bot(response));

      // Use Text-to-Speech to read the response
      _speechService.speak(response);
    } catch (e) {
      addMessage(ChatMessage.error('Error: ${e.toString()}'));
    } finally {
      isLoading.value = false;
    }
  }

  void startListening() async {
    await _speechService.startListening(onResult: (result) {
      sendMessage(result);
    });
  }

  void stopListening() => _speechService.stopListening();
}

