
enum MessageType { user, bot }

class ChatMessage {
  final String message;
  final MessageType type;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.message,
    required this.type,
    required this.timestamp,
    this.isError = false,
  });

  factory ChatMessage.user(String message) {
    return ChatMessage(
      message: message,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.bot(String message) {
    return ChatMessage(
      message: message,
      type: MessageType.bot,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.error(String message) {
    return ChatMessage(
      message: message,
      type: MessageType.bot,
      timestamp: DateTime.now(),
      isError: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'type': type.index,
      'timestamp': timestamp.toIso8601String(),
      'isError': isError,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'],
      type: MessageType.values[json['type']],
      timestamp: DateTime.parse(json['timestamp']),
      isError: json['isError'] ?? false,
    );
  }
}
