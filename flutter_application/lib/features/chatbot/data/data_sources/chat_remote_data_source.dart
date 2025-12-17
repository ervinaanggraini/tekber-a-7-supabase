import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/chat_conversation.dart';
import '../utils/transaction_parser.dart';
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
    File? imageFile,
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

  bool _isAffirmative(String text) {
    return isAffirmativeText(text);
  }

  bool _isNegative(String text) {
    return isNegativeText(text);
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

    // Check if conversation with this persona already exists
    final existingConversation = await supabase
        .from('chat_conversations')
        .select()
        .eq('user_id', userId)
        .eq('persona', persona.value)
        .eq('is_archived', false)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    // Return existing conversation if found
    if (existingConversation != null) {
      print('📌 Using existing conversation for ${persona.name}');
      return ChatConversationModel.fromJson(existingConversation);
    }

    // Create new conversation if none exists
    print('✨ Creating new conversation for ${persona.name}');
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
    File? imageFile,
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
        
        await supabase.storage.from('chat-images').upload(
          filePath,
          imageFile,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
          ),
        );
        
        imageUrl = supabase.storage.from('chat-images').getPublicUrl(filePath);
        print('✅ Image uploaded: $imageUrl');
      } catch (e) {
        print('❌ Image upload failed: $e');
        // Continue without image if upload fails
      }
    }
    
    // Parse message for potential transaction (but do NOT auto-save)
    Map<String, dynamic>? parsedTransaction;
    try {
      parsedTransaction = parseTransactionFromText(message);
      if (parsedTransaction != null) {
        print('🔍 Parsed potential transaction: $parsedTransaction');
      }
    } catch (e) {
      print('⚠️ Transaction parsing failed: $e');
    }

    // NOTE: User message akan di-insert oleh Edge Function
    // Tidak perlu insert di sini untuk menghindari duplicate
    Map<String, dynamic>? insertedUserMessage;

    // If there's a pending confirmation, interpret this message as response
    try {
        // Fetch the most recent assistant confirmation message specifically
        final lastAssistant = await supabase
          .from('chat_messages')
          .select()
          .eq('conversation_id', conversationId)
          .eq('role', 'assistant')
          .eq('intent', 'confirm_transaction')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (lastAssistant != null && lastAssistant['role'] == 'assistant' && lastAssistant['intent'] == 'confirm_transaction') {
        final isAffirmative = isAffirmativeText(message);
        final isNegative = isNegativeText(message);

        if (isAffirmative) {
          final data = lastAssistant['extracted_data'] as Map<String, dynamic>?;
          if (data != null) {
            final created = await _createTransactionFromParsed(data);
              if (created != null) {
                final createdType = (data['type'] as String?) ?? 'expense';
                final humanType = createdType == 'income' ? 'Pemasukan' : 'Pengeluaran';
              // update user message to attach transaction_id
              if (insertedUserMessage != null) {
                await supabase.from('chat_messages').update({
                  'intent': 'record_transaction',
                  'transaction_id': created['id'],
                }).eq('id', insertedUserMessage['id']);
              }

              // update assistant confirm message to reflect saved transaction
              await supabase.from('chat_messages').update({
                'content': '✅ $humanType dicatat: ${created['description'] ?? ''} - Rp${(created['amount'] as num).toInt()}',
                'transaction_id': created['id'],
              }).eq('id', lastAssistant['id']);

              // insert persona-specific confirmation reply (yes)
              final personaVal = lastAssistant['persona'] as String?;
              String personaYesReply;
              switch (personaVal) {
                case 'wise_mentor':
                  personaYesReply = '🫡 Baik, aku sudah catat transaksimu. Mari kita lanjutkan membangun fondasi finansial yang kuat. Ada yang ingin kamu diskusikan?';
                  break;
                case 'supportive_cheerleader':
                  personaYesReply = '💖 Oke bestie, aku udah catat nih! Semangat terus ya kelola keuangannya! Cerita lagi dong!✨';
                  break;
                case 'angry_mom':
                default:
                  personaYesReply = '😤 Oke, Ibu catat ya! Jangan lupa, uang itu dicari susah payah loh. Ayo ceritakan lebih detail tentang transaksimu!';
              }

              await supabase.from('chat_messages').insert({
                'conversation_id': conversationId,
                'role': 'assistant',
                'content': personaYesReply,
                'persona': lastAssistant['persona'],
                'transaction_id': created['id'],
              });

              // Update conversation last_message_at
              await supabase
                  .from('chat_conversations')
                  .update({'last_message_at': DateTime.now().toIso8601String()})
                  .eq('id', conversationId);

              await Future.delayed(const Duration(milliseconds: 300));
              final messages = await getMessages(conversationId);
              return messages.last;
            }
          }
        }

        if (isNegative) {
          final personaVal = lastAssistant['persona'] as String?;
          String personaNoReply;
          switch (personaVal) {
            case 'wise_mentor':
              personaNoReply = '🫡 Baik, ada hal lain yang ingin kamu diskusikan?';
              break;
            case 'supportive_cheerleader':
              personaNoReply = '💖 Aman bestie, terus ada cerita apa lagi?';
              break;
            case 'angry_mom':
            default:
              personaNoReply = '😤 Oke, kalau tidak mau. Ceritakan transaksimu yang lain!';
          }

          // Insert a new assistant message with the persona reply so it appears as a separate message
          await supabase.from('chat_messages').insert({
            'conversation_id': conversationId,
            'role': 'assistant',
            'content': personaNoReply,
            'persona': personaVal,
          });

          await supabase
              .from('chat_conversations')
              .update({'last_message_at': DateTime.now().toIso8601String()})
              .eq('id', conversationId);

          await Future.delayed(const Duration(milliseconds: 300));
          final messages = await getMessages(conversationId);
          return messages.last;
        }
      }
    } catch (e) {
      print('⚠️ Error while handling confirmation response: $e');
    }

    // If parsing detected a potential transaction and there's no pending confirmation, ask for confirmation
    if (parsedTransaction != null) {
      try {
        final conversation = await supabase
            .from('chat_conversations')
            .select('persona')
            .eq('id', conversationId)
            .single();

        final persona = conversation['persona'] as String?;

        final detectedType = parsedTransaction['type'] as String? ?? 'expense';
        final humanType = detectedType == 'income' ? 'pemasukan' : 'pengeluaran';
        final amount = (parsedTransaction['amount'] as num).toInt();
        final desc = parsedTransaction['description'] ?? '';
        final confirmationText = detectedType == 'income'
          ? 'Sepertinya aku mendeteksi adanya pemasukan: ${desc} sebesar Rp${amount}. Benar begitu? Mau aku catat?'
          : 'Sepertinya aku mendeteksi adanya pengeluaran: ${desc} sebesar Rp${amount}. Benar begitu? Mau aku catat?';

        await supabase.from('chat_messages').insert({
          'conversation_id': conversationId,
          'role': 'assistant',
          'content': confirmationText,
          'persona': persona,
          'intent': 'confirm_transaction',
          'extracted_data': parsedTransaction,
        });

        await supabase
            .from('chat_conversations')
            .update({'last_message_at': DateTime.now().toIso8601String()})
            .eq('id', conversationId);

        await Future.delayed(const Duration(milliseconds: 300));
        final messages = await getMessages(conversationId);
        return messages.last;
      } catch (e) {
        print('❌ Failed to insert confirmation message: $e');
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
        
          // Previously we inserted the user message early — don't duplicate here.

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
          // no transaction id here — only set after user confirms
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

  Future<Map<String, dynamic>?> _detectAndCreateTransactionIfAny(String message) async {
    // Deprecated: creation now handled in _createTransactionFromParsed when confirmed
    return null;
  }

  Future<Map<String, dynamic>?> _createTransactionFromParsed(Map<String, dynamic> parsed) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final parsedType = (parsed['type'] as String?) ?? 'expense';
      final categoryId = await _findCategoryId(parsed['description'] as String?, parsedType);

      final insertData = {
        'user_id': userId,
        'category_id': categoryId,
        'type': parsedType,
        'amount': parsed['amount'],
        'description': parsed['description'],
        'merchant_name': parsed['merchant'],
        'transaction_date': DateTime.now().toIso8601String(),
        'input_method': 'ai_chat',
      };

      final response = await supabase.from('transactions').insert(insertData).select().single();
      if (response == null) return null;

      return {
        'id': response['id'],
        'amount': parsed['amount'],
        'description': parsed['description'],
        'merchant': parsed['merchant'],
        'category_id': categoryId,
      };
    } catch (e) {
      print('❌ Error creating transaction: $e');
      return null;
    }
  }

  

  Future<String?> _findCategoryId(String? description, String type) async {
    try {
      if (description != null) {
        final keywords = ['makanan', 'makan', 'minum', 'makanan & minuman', 'belanja', 'transport'];
        final lower = description.toLowerCase();
        for (final kw in keywords) {
          if (lower.contains(kw)) {
            final resp = await supabase
                .from('categories')
                .select()
                .ilike('name', '%$kw%')
                .eq('type', type)
                .maybeSingle();
            if (resp != null && resp['id'] != null) return resp['id'] as String;
          }
        }
      }

      // Fallback: first category of requested type
      final first = await supabase.from('categories').select().eq('type', type).limit(1).maybeSingle();
      if (first != null && first['id'] != null) return first['id'] as String;
    } catch (e) {
      print('❌ Error finding category: $e');
    }
    return null;
  }
}
