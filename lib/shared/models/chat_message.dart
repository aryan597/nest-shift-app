class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String> devicesAffected;
  final bool isTypingIndicator;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.devicesAffected = const [],
    this.isTypingIndicator = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        text: (json['message'] ?? json['text'] ?? '') as String,
        isUser: json['role'] == 'user',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
        devicesAffected: (json['devices_affected'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    List<String>? devicesAffected,
    bool? isTypingIndicator,
  }) =>
      ChatMessage(
        id: id ?? this.id,
        text: text ?? this.text,
        isUser: isUser ?? this.isUser,
        timestamp: timestamp ?? this.timestamp,
        devicesAffected: devicesAffected ?? this.devicesAffected,
        isTypingIndicator: isTypingIndicator ?? this.isTypingIndicator,
      );

  static ChatMessage typing() => ChatMessage(
        id: 'typing_indicator',
        text: '',
        isUser: false,
        timestamp: DateTime.now(),
        isTypingIndicator: true,
      );

  static ChatMessage user(String text) => ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      );

  static ChatMessage ai({
    required String text,
    List<String> devicesAffected = const [],
  }) =>
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
        devicesAffected: devicesAffected,
      );
}
