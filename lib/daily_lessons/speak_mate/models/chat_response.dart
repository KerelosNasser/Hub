class ChatResponse {
  final String content;
  final String? correction;
  final List<String> suggestions;
  final String source;
  final int tokensUsed;

  ChatResponse({
    required this.content,
    this.correction,
    this.suggestions = const [],
    required this.source,
    required this.tokensUsed,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      content: json['content'],
      correction: json['correction'],
      suggestions: List<String>.from(json['suggestions'] ?? []),
      source: json['source'],
      tokensUsed: json['tokensUsed'],
    );
  }
}