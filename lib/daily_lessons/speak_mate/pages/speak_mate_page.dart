import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../controllers/speak_mate_controller.dart';
import '../models/chat_message.dart';
import '../services/speech_service.dart';

class SpeakMatePage extends StatelessWidget {
  final SpeakMateController controller = Get.put(SpeakMateController());
  final SpeechService speechService = Get.find<SpeechService>();

  SpeakMatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _buildHeader(context),
            Expanded(
              child: Obx(() => _buildChatList(context)),
            ),
            _buildInputSection(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Icon(Icons.chat_bubble_outline, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'SpeakMate',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.pink.shade800,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () => _showInfoDialog(context),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade800, Colors.pink.shade600],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            '🎯 Practice English Conversation',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(duration: 600.ms),
          SizedBox(height: 8),
          Obx(() => Text(
            controller.chatMessages.isEmpty
                ? 'Tap the mic to start speaking!'
                : 'Messages: ${controller.chatMessages.length}',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          )).animate().fadeIn(delay: 300.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildChatList(BuildContext context) {
    if (controller.chatMessages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      reverse: true,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: controller.chatMessages.length,
      itemBuilder: (context, index) {
        final reversedIndex = controller.chatMessages.length - 1 - index;
        final message = controller.chatMessages[reversedIndex];
        return _buildChatBubble(message, context);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.comments,
            size: 80,
            color: Colors.grey.shade300,
          ).animate().scale(duration: 600.ms),
          SizedBox(height: 24),
          Text(
            'Ready to practice English?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ).animate().fadeIn(delay: 300.ms),
          SizedBox(height: 8),
          Text(
            'Tap the microphone to start',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message, BuildContext context) {
    final isUser = message.type == MessageType.user;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _buildAvatar(false),
          SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Colors.pink.shade400
                        : message.isError
                            ? Colors.red.shade400
                            : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.message,
                        style: TextStyle(
                          color: isUser || message.isError
                              ? Colors.white
                              : Colors.black87,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      if (controller.isLoading.value &&
                          !isUser &&
                          message == controller.chatMessages.last)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white70),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Thinking...',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ).animate().slideX(
                    begin: isUser ? 0.2 : -0.2,
                    duration: 300.ms,
                    curve: Curves.easeOut),
                SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          if (isUser) _buildAvatar(true),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isUser ? Colors.pink.shade600 : Colors.blue.shade600,
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        size: 20,
        color: Colors.white,
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Obx(() => speechService.isListening.value
              ? _buildListeningIndicator()
              : SizedBox.shrink()),
          Row(
            children: [
              Expanded(
                child: Obx(() => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: speechService.isListening.value ? 60 : 0,
                  child: speechService.isListening.value
                      ? Center(
                          child: Text(
                            speechService.recognizedText.value.isEmpty
                                ? 'Listening...'
                                : speechService.recognizedText.value,
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : SizedBox.shrink(),
                )),
              ),
              SizedBox(width: 12),
              _buildMicButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListeningIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3,
          (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: 2),
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.pink.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scaleY(
                begin: 0.3,
                end: 1.0,
                duration: 600.ms,
                delay: Duration(milliseconds: index * 100),
              ),
        ),
      ),
    );
  }

  Widget _buildMicButton(BuildContext context) {
    return Obx(() {
      final isListening = speechService.isListening.value;
      final isLoading = controller.isLoading.value;
      
      return GestureDetector(
        onTap: isLoading
            ? null
            : () {
                if (isListening) {
                  controller.stopListening();
                } else {
                  controller.startListening();
                }
              },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isListening
                  ? [Colors.red.shade600, Colors.red.shade800]
                  : [Colors.pink.shade600, Colors.pink.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: (isListening ? Colors.red : Colors.pink)
                    .withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            isListening ? Icons.stop : Icons.mic,
            color: Colors.white,
            size: 28,
          ),
        ),
      )
          .animate(target: isListening ? 1 : 0)
          .scale(end: Offset(1.1, 1.1), duration: 300.ms)
          .then()
          .scale(end: Offset(1.0, 1.0), duration: 300.ms);
    });
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.pink.shade600),
            SizedBox(width: 8),
            Text('About SpeakMate'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SpeakMate is your AI-powered English learning companion!',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            _buildInfoItem(Icons.mic, 'Tap mic to start speaking'),
            _buildInfoItem(Icons.chat, 'Get instant AI responses'),
            _buildInfoItem(Icons.volume_up, 'Listen to pronunciations'),
            _buildInfoItem(Icons.offline_bolt, 'Works completely offline'),
            SizedBox(height: 12),
            Text(
              'Note: Make sure Ollama is running locally on port 5000.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.pink.shade400),
          SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
