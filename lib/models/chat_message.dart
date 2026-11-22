class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String> quickFollowUps;
  final bool isDemo;
  final bool isError;
  final bool isStreaming;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.quickFollowUps = const [],
    this.isDemo = false,
    this.isError = false,
    this.isStreaming = false,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    List<String>? quickFollowUps,
    bool? isDemo,
    bool? isError,
    bool? isStreaming,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      quickFollowUps: quickFollowUps ?? this.quickFollowUps,
      isDemo: isDemo ?? this.isDemo,
      isError: isError ?? this.isError,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'quickFollowUps': quickFollowUps,
        'isDemo': isDemo,
        'isError': isError,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String? ?? '',
        text: json['text'] as String? ?? '',
        isUser: json['isUser'] as bool? ?? false,
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
        quickFollowUps: (json['quickFollowUps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        isDemo: json['isDemo'] as bool? ?? false,
        isError: json['isError'] as bool? ?? false,
      );
}
