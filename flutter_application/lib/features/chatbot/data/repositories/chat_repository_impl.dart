import 'package:image_picker/image_picker.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../data_sources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ChatConversation>> getConversations() async {
    return await remoteDataSource.getConversations();
  }

  @override
  Future<ChatConversation?> getConversation(String conversationId) async {
    return await remoteDataSource.getConversation(conversationId);
  }

  @override
  Future<ChatConversation> createConversation(ChatPersona persona) async {
    return await remoteDataSource.createConversation(persona);
  }

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    return await remoteDataSource.getMessages(conversationId);
  }

  @override
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String message,
    dynamic imageFile,
  }) async {
    return await remoteDataSource.sendMessage(
      conversationId: conversationId,
      message: message,
      imageFile: imageFile,
    );
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await remoteDataSource.deleteConversation(conversationId);
  }

  @override
  Future<void> archiveConversation(String conversationId, bool archived) async {
    await remoteDataSource.archiveConversation(conversationId, archived);
  }
}
