import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.conversationId,
    required super.role,
    required super.content,
    super.persona,
    super.intent,
    super.extractedData,
    super.transactionId,
    required super.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      persona: json['persona'] as String?,
      intent: json['intent'] as String?,
      extractedData: json['extracted_data'] != null
          ? Map<String, dynamic>.from(json['extracted_data'] as Map)
          : null,
      transactionId: json['transaction_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'role': role,
      'content': content,
      if (persona != null) 'persona': persona,
      if (intent != null) 'intent': intent,
      if (extractedData != null) 'extracted_data': extractedData,
      if (transactionId != null) 'transaction_id': transactionId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
