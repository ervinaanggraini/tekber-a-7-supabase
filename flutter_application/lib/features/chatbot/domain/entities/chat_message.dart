import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String conversationId;
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final String? persona;
  final String? intent;
  final Map<String, dynamic>? extractedData;
  final String? transactionId;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.persona,
    this.intent,
    this.extractedData,
    this.transactionId,
    required this.createdAt,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  @override
  List<Object?> get props => [
        id,
        conversationId,
        role,
        content,
        persona,
        intent,
        extractedData,
        transactionId,
        createdAt,
      ];
}
