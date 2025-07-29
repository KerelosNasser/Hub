class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageStatus status;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'status': status.index,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'],
    content: json['content'],
    isUser: json['isUser'],
    timestamp: DateTime.parse(json['timestamp']),
    status: MessageStatus.values[json['status'] ?? 0],
  );
}

enum MessageStatus { sending, sent, error }

class DailyStats {
  final int messageCount;
  final DateTime date;
  final int conversationMinutes;

  DailyStats({
    required this.messageCount,
    required this.date,
    this.conversationMinutes = 0,
  });

  Map<String, dynamic> toJson() => {
    'messageCount': messageCount,
    'date': date.toIso8601String(),
    'conversationMinutes': conversationMinutes,
  };

  factory DailyStats.fromJson(Map<String, dynamic> json) => DailyStats(
    messageCount: json['messageCount'],
    date: DateTime.parse(json['date']),
    conversationMinutes: json['conversationMinutes'] ?? 0,
  );
}