import '../../domain/entities/chat_conversation.dart';

class ChatConversationModel extends ChatConversation {
  const ChatConversationModel({
    required super.id,
    required super.userId,
    super.title,
    required super.persona,
    super.contextSummary,
    super.lastMessageAt,
    super.isArchived,
    required super.createdAt,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    return ChatConversationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String?,
      persona: ChatPersona.fromString(json['persona'] as String),
      contextSummary: json['context_summary'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      if (title != null) 'title': title,
      'persona': persona.value,
      if (contextSummary != null) 'context_summary': contextSummary,
      if (lastMessageAt != null)
        'last_message_at': lastMessageAt!.toIso8601String(),
      'is_archived': isArchived,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
