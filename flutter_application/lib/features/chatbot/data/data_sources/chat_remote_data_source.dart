import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/chat_conversation.dart';
import '../models/chat_conversation_model.dart';
import '../models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatConversationModel>> getConversations();
  Future<ChatConversationModel?> getConversation(String conversationId);
  Future<ChatConversationModel> createConversation(ChatPersona persona);
  Future<List<ChatMessageModel>> getMessages(String conversationId);
  Future<ChatMessageModel> sendMessage({
    required String conversationId,
    required String message,
    dynamic imageFile,
  });
  Future<void> deleteConversation(String conversationId);
  Future<void> archiveConversation(String conversationId, bool archived);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient supabase;

  ChatRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<ChatConversationModel>> getConversations() async {
    final response = await supabase
        .from('chat_conversations')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ChatConversationModel.fromJson(json))
        .toList();
  }

  @override
  Future<ChatConversationModel?> getConversation(String conversationId) async {
    final response = await supabase
        .from('chat_conversations')
        .select()
        .eq('id', conversationId)
        .maybeSingle();

    if (response == null) return null;
    return ChatConversationModel.fromJson(response);
  }

  @override
  Future<ChatConversationModel> createConversation(ChatPersona persona) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await supabase
        .from('chat_conversations')
        .insert({
          'user_id': userId,
          'persona': persona.value,
          'title': 'Chat dengan ${persona.name}',
        })
        .select()
        .single();

    return ChatConversationModel.fromJson(response);
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String conversationId) async {
    final response = await supabase
        .from('chat_messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => ChatMessageModel.fromJson(json))
        .toList();
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String conversationId,
    required String message,
    dynamic imageFile,
  }) async {
    print('🔵 Sending message to conversation: $conversationId');
    print('📝 Message: $message');
    
    String? imageUrl;
    
    // Upload image if provided
    if (imageFile != null) {
      print('📸 Uploading image...');
      try {
        final userId = supabase.auth.currentUser?.id;
        if (userId == null) throw Exception('User not authenticated');
        
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = '$userId/$conversationId/$fileName';

        // Handle both File and XFile types
        if (imageFile is File) {
          // Mobile/Desktop: File type
          await supabase.storage.from('chat-images').upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
            ),
          );
        } else {
          // Web or XFile: convert to bytes
          final bytes = await (imageFile as dynamic).readAsBytes();
          await supabase.storage.from('chat-images').uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
            ),
          );
        }

        imageUrl = supabase.storage.from('chat-images').getPublicUrl(filePath);
        print('✅ Image uploaded: $imageUrl');
      } catch (e) {
        print('❌ Image upload failed: $e');
        // Continue without image if upload fails
      }
    }
    
    try {
      // Call Edge Function with retry logic
      print('🚀 Calling Edge Function...');
      final response = await supabase.functions.invoke(
        'ai-chat',
        body: {
          'conversationId': conversationId,
          'message': message,
          if (imageUrl != null) 'imageUrl': imageUrl,
        },
      );

      print('✅ Edge Function response received');
      
      if (response.data != null) {
        print('📦 Response data: ${response.data}');
      }
      
      // Small delay to ensure database consistency
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Retry fetch with multiple attempts
      for (int attempt = 0; attempt < 3; attempt++) {
        print('📥 Fetching messages (attempt ${attempt + 1}/3)...');
        final messages = await getMessages(conversationId);
        print('📊 Found ${messages.length} messages');
        
        if (messages.isNotEmpty) {
          print('✅ Messages found, returning last message');
          return messages.last;
        }
        
        // Wait before retry
        if (attempt < 2) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
      
      throw Exception('No messages found after sending');
      
    } catch (e) {
      print('❌ Edge Function error: $e');
      print('🔄 Using fallback response...');
      
      // Fallback: Direct database insert with persona-based response
      try {
        final conversation = await supabase
            .from('chat_conversations')
            .select('persona')
            .eq('id', conversationId)
            .single();
        
        final persona = conversation['persona'] as String?;
        
        // Save user message
        await supabase.from('chat_messages').insert({
          'conversation_id': conversationId,
          'role': 'user',
          'content': message,
          if (imageUrl != null) 'image_url': imageUrl,
        });
        print('✅ User message saved (fallback)');

        // Generate response based on persona
        String aiResponse;
        if (imageUrl != null) {
          // If there's an image, provide a vision-related response
          aiResponse = '🤖 Maaf, saat ini saya tidak bisa memproses gambar. Silakan coba lagi nanti atau jelaskan dengan teks!';
        } else {
          switch (persona) {
            case 'angry_mom':
              aiResponse = '😤 Oke, Ibu catat ya! Jangan lupa, uang itu dicari susah payah loh. Ayo ceritakan lebih detail transaksimu!';
              break;
            case 'supportive_cheerleader':
              aiResponse = '💖 Oke bestie! Aku udah catat nih! Semangat terus ya kelola keuangannya! Cerita lagi dong! ✨';
              break;
            case 'wise_mentor':
              aiResponse = '🧙‍♂️ Baik, saya telah mencatat transaksi Anda. Mari kita lanjutkan membangun fondasi finansial yang kuat. Ada yang ingin Anda diskusikan?';
              break;
            default:
              aiResponse = '🤖 Pesan Anda sudah diterima! Ada yang bisa saya bantu lagi?';
          }
        }

        await supabase.from('chat_messages').insert({
          'conversation_id': conversationId,
          'role': 'assistant',
          'content': aiResponse,
          'persona': persona,
        });
        print('✅ AI response saved (fallback)');
        
        // Update last message time
        await supabase
            .from('chat_conversations')
            .update({'last_message_at': DateTime.now().toIso8601String()})
            .eq('id', conversationId);
        
        await Future.delayed(const Duration(milliseconds: 300));
        final messages = await getMessages(conversationId);
        
        if (messages.isEmpty) {
          throw Exception('No messages found after fallback');
        }
        
        return messages.last;
      } catch (dbError) {
        print('❌ Fallback also failed: $dbError');
        rethrow;
      }
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await supabase.from('chat_conversations').delete().eq('id', conversationId);
  }

  @override
  Future<void> archiveConversation(String conversationId, bool archived) async {
    await supabase
        .from('chat_conversations')
        .update({'is_archived': archived}).eq('id', conversationId);
  }
}
