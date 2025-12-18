import 'package:image_picker/image_picker.dart';
import '../entities/chat_conversation.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  /// Get all conversations for the current user
  Future<List<ChatConversation>> getConversations();

  /// Get a specific conversation by ID
  Future<ChatConversation?> getConversation(String conversationId);

  /// Create a new conversation
  Future<ChatConversation> createConversation(ChatPersona persona);

  /// Get messages for a conversation
  Future<List<ChatMessage>> getMessages(String conversationId);

  /// Send a message and get AI response
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String message,
    // Accept either a dart:io File (mobile) or XFile / Uint8List for web
    dynamic imageFile,
  });

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId);

  /// Archive a conversation
  Future<void> archiveConversation(String conversationId, bool archived);
}
