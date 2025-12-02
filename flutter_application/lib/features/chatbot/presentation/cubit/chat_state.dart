import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ConversationsLoaded extends ChatState {
  final List<ChatConversation> conversations;

  const ConversationsLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class ChatConversationActive extends ChatState {
  final ChatConversation conversation;
  final List<ChatMessage> messages;
  final bool isSending;

  const ChatConversationActive({
    required this.conversation,
    required this.messages,
    this.isSending = false,
  });

  ChatConversationActive copyWith({
    ChatConversation? conversation,
    List<ChatMessage>? messages,
    bool? isSending,
  }) {
    return ChatConversationActive(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [conversation, messages, isSending];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
