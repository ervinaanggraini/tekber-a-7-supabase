import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'dart:io';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';

@injectable
class ChatCubit extends Cubit<ChatState> {
  final ChatRepository repository;

  ChatCubit(this.repository) : super(ChatInitial());

  Future<void> loadConversations() async {
    try {
      emit(ChatLoading());
      final conversations = await repository.getConversations();
      emit(ConversationsLoaded(conversations));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> createAndStartConversation(ChatPersona persona) async {
    try {
      emit(ChatLoading());
      final conversation = await repository.createConversation(persona);
      final messages = await repository.getMessages(conversation.id);
      emit(ChatConversationActive(
        conversation: conversation,
        messages: messages,
      ));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> openConversation(String conversationId) async {
    try {
      emit(ChatLoading());
      final conversation = await repository.getConversation(conversationId);
      if (conversation == null) {
        emit(const ChatError('Conversation not found'));
        return;
      }
      final messages = await repository.getMessages(conversationId);
      emit(ChatConversationActive(
        conversation: conversation,
        messages: messages,
      ));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> sendMessage(String message, {File? imageFile}) async {
    final currentState = state;
    if (currentState is! ChatConversationActive) return;

    try {
      // Create optimistic user message (show immediately with image preview)
      final optimisticMessage = ChatMessage(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        conversationId: currentState.conversation.id,
        role: 'user',
        content: message,
        createdAt: DateTime.now(),
        imageUrl: imageFile != null ? 'loading' : null, // Temporary marker for loading image
      );

      // Update UI with user message immediately + set sending state
      emit(currentState.copyWith(
        messages: [...currentState.messages, optimisticMessage],
        isSending: true,
      ));

      // Send message and get response
      await repository.sendMessage(
        conversationId: currentState.conversation.id,
        message: message,
        imageFile: imageFile,
      );

      // Reload messages with actual data from server
      final messages =
          await repository.getMessages(currentState.conversation.id);
      emit(currentState.copyWith(
        messages: messages,
        isSending: false,
      ));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await repository.deleteConversation(conversationId);
      await loadConversations();
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> archiveConversation(String conversationId, bool archived) async {
    try {
      await repository.archiveConversation(conversationId, archived);
      await loadConversations();
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}
