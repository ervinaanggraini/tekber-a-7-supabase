import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../domain/entities/chat_conversation.dart';
import '../domain/entities/chat_message.dart';
import 'cubit/chat_cubit.dart';
import 'cubit/chat_state.dart';

class ChatScreen extends StatefulWidget {
  final String? conversationId;

  const ChatScreen({super.key, this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    if (widget.conversationId != null) {
      context.read<ChatCubit>().openConversation(widget.conversationId!);
    } else {
      // Show persona selector immediately if no conversation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPersonaSelector();
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1024,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil foto: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : AppColors.f4e8da,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Sumber Gambar',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.pink[200] : AppColors.b93160,
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: Icon(Icons.photo_library, color: isDark ? Colors.pink[200] : AppColors.b93160),
              title: Text(
                'Galeri',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.b93160,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: isDark ? Colors.pink[200] : AppColors.b93160),
              title: Text(
                'Kamera',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.b93160,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _takePicture();
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  String _getPersonaImagePath(ChatPersona persona) {
    switch (persona) {
      case ChatPersona.angryMom:
        return 'assets/images/finny.png';
      case ChatPersona.supportiveCheerleader:
        return 'assets/images/mona.png';
      case ChatPersona.wiseMentor:
        return 'assets/images/vesto.png';
    }
  }

  void _showPersonaSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: isDark ? Colors.grey[850] : AppColors.f4e8da,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: isDark ? BorderSide(color: Colors.grey[700]!, width: 1) : BorderSide.none,
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Kepribadian',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.pink[200] : AppColors.b93160,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ChatPersona.values.map((persona) {
                  return _PersonaAvatar(
                    persona: persona,
                    onTap: () {
                      Navigator.pop(context);
                      context.read<ChatCubit>().createAndStartConversation(persona);
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : AppColors.f4e8da,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            if (state is ChatConversationActive) {
              return Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        _getPersonaImagePath(state.conversation.persona),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.ffb4c2,
                            child: Center(
                              child: Text(
                                state.conversation.persona.emoji,
                                style: TextStyle(fontSize: 20.sp),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.conversation.persona.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.b93160,
                        ),
                      ),
                      Text(
                        state.conversation.persona.description,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.ac9780,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
            return const Text('AI Chatbot');
          },
        ),
      ),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatConversationActive) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          if (state is ChatInitial) {
            return _EmptyStateView(onStartChat: _showPersonaSelector);
          }

          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: TextStyle(color: isDark ? Colors.pink[200] : AppColors.b93160),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: _showPersonaSelector,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state is ChatConversationActive) {
            return Column(
              children: [
                Expanded(
                  child: state.messages.isEmpty
                      ? _EmptyMessagesView(
                          persona: state.conversation.persona,
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(16.w),
                          itemCount: state.messages.length + (state.isSending ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Show typing indicator as last item when sending
                            if (index == state.messages.length && state.isSending) {
                              return _TypingIndicator(persona: state.conversation.persona.value);
                            }
                            
                            final message = state.messages[index];
                            return _ChatBubble(message: message);
                          },
                        ),
                ),
                _MessageInput(
                  controller: _messageController,
                  selectedImage: _selectedImage,
                  onPickImage: _showImageSourceDialog,
                  onRemoveImage: _removeImage,
                  onSend: () {
                    if (_messageController.text.trim().isNotEmpty || _selectedImage != null) {
                      context
                          .read<ChatCubit>()
                          .sendMessage(
                            _messageController.text.trim(),
                            imageFile: _selectedImage,
                          );
                      _messageController.clear();
                      setState(() {
                        _selectedImage = null;
                      });
                    }
                  },
                  enabled: !state.isSending,
                ),
              ],
            );
          }

          return _EmptyStateView(onStartChat: _showPersonaSelector);
        },
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  final VoidCallback onStartChat;

  const _EmptyStateView({required this.onStartChat});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              gradient: AppColors.linier,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 60.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Mulai Chat dengan AI',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.pink[200] : AppColors.b93160,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Pilih asisten AI untuk membantu\nkelola keuanganmu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.ac9780,
            ),
          ),
          SizedBox(height: 32.h),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.linier,
              borderRadius: BorderRadius.circular(30.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ffb4c2.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onStartChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              child: Text(
                'Mulai Chat',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMessagesView extends StatelessWidget {
  final ChatPersona persona;

  const _EmptyMessagesView({required this.persona});

  String _getPersonaImagePath(ChatPersona persona) {
    switch (persona) {
      case ChatPersona.angryMom:
        return 'assets/images/finny.png';
      case ChatPersona.supportiveCheerleader:
        return 'assets/images/mona.png';
      case ChatPersona.wiseMentor:
        return 'assets/images/vesto.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  _getPersonaImagePath(persona),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.f4e8da,
                      child: Center(
                        child: Text(
                          persona.emoji,
                          style: TextStyle(fontSize: 48.sp),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Hai! Aku ${persona.name}',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.pink[200] : AppColors.b93160,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _getGreeting(persona),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.ac9780,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting(ChatPersona persona) {
    switch (persona) {
      case ChatPersona.angryMom:
        return 'Aku akan bantu kamu jaga pengeluaran biar nggak boros! Ayo cerita transaksimu hari ini.';
      case ChatPersona.supportiveCheerleader:
        return 'Aku di sini untuk support kamu! Cerita aja transaksimu, aku siap dengerin dengan senang hati.';
      case ChatPersona.wiseMentor:
        return 'Aku akan bantu kamu mencapai tujuan finansial. Mari kita mulai dengan mencatat transaksimu.';
    }
  }
}

class _PersonaCard extends StatelessWidget {
  final ChatPersona persona;
  final VoidCallback onTap;

  const _PersonaCard({
    required this.persona,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    gradient: AppColors.linier,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      persona.emoji,
                      style: TextStyle(fontSize: 24.sp),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        persona.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.pink[200] : AppColors.b93160,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        persona.description,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.ac9780,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: AppColors.ac9780,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonaAvatar extends StatelessWidget {
  final ChatPersona persona;
  final VoidCallback onTap;

  const _PersonaAvatar({
    required this.persona,
    required this.onTap,
  });

  String _getImagePath(ChatPersona persona) {
    switch (persona) {
      case ChatPersona.angryMom:
        return 'assets/images/finny.png';
      case ChatPersona.supportiveCheerleader:
        return 'assets/images/mona.png';
      case ChatPersona.wiseMentor:
        return 'assets/images/vesto.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                _getImagePath(persona),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: isDark ? Colors.grey[700] : AppColors.f4e8da,
                    child: Center(
                      child: Text(
                        persona.emoji,
                        style: TextStyle(fontSize: 32.sp),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            persona.name,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.pink[200] : AppColors.b93160,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  String _getPersonaImage(String persona) {
    switch (persona) {
      case 'angry_mom':
        return 'assets/images/finny.png';
      case 'supportive_cheerleader':
        return 'assets/images/mona.png';
      case 'wise_mentor':
        return 'assets/images/vesto.png';
      default:
        return 'assets/images/vesto.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.isUser;
    
    // Debug print
    print('💬 Rendering message:');
    print('   - Role: ${message.role}');
    print('   - Content: ${message.content}');
    print('   - ImageUrl: ${message.imageUrl}');
    print('   - Has image: ${message.imageUrl != null && message.imageUrl!.isNotEmpty}');

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: message.persona != null
                    ? Image.asset(
                        _getPersonaImage(message.persona!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.ffb4c2,
                            child: Center(
                              child: Text(
                                '🤖',
                                style: TextStyle(fontSize: 16.sp),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: AppColors.ffb4c2,
                        child: Center(
                          child: Text(
                            '🤖',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: isUser ? AppColors.linier : null,
                color: isUser ? null : (isDark ? Colors.grey[850] : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: isUser ? Radius.circular(16.r) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : Radius.circular(16.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.imageUrl != null && message.imageUrl!.isNotEmpty && message.imageUrl != 'loading') ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        message.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150.h,
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey[600],
                                size: 40.sp,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 150.h,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (message.content.isNotEmpty) SizedBox(height: 8.h),
                  ],
                  if (message.content.isNotEmpty)
                    Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isUser ? Colors.white : (isDark ? Colors.white : AppColors.b93160),
                      ),
                    ),
                  // If this assistant message is a confirmation request, show quick actions
                  if (!isUser && message.intent == 'confirm_transaction') ...[
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 36.h,
                          child: ElevatedButton(
                            onPressed: () {
                              final cubit = context.read<ChatCubit>();
                              cubit.sendMessage('ya');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.b93160,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                              elevation: 0,
                            ),
                            child: Text(
                              'Ya',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        SizedBox(
                          height: 36.h,
                          child: ElevatedButton(
                            onPressed: () {
                              final cubit = context.read<ChatCubit>();
                              cubit.sendMessage('tidak');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.b93160,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                              elevation: 0,
                            ),
                            child: Text(
                              'Tidak',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (message.transactionId != null) SizedBox(height: 8.h),
                  if (message.transactionId != null)
                    GestureDetector(
                      onTap: () {
                        // For now, just show simple snackbar with transaction info
                        final amt = message.extractedData != null ? message.extractedData!['amount'] : null;
                        final desc = message.extractedData != null ? message.extractedData!['description'] : null;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Transaksi dicatat: ${desc ?? ''} ${amt != null ? ' - Rp${amt.toInt()}' : ''}')),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.white.withOpacity(0.08) : (isDark ? Colors.grey[800] : AppColors.f4e8da),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long, size: 14.sp, color: isUser ? Colors.white : AppColors.b93160),
                            SizedBox(width: 6.w),
                            Text(
                              'Transaksi dicatat',
                              style: TextStyle(fontSize: 12.sp, color: isUser ? Colors.white : AppColors.b93160),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 8.w),
            CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.eed180,
              child: Icon(
                Icons.person,
                size: 16.sp,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final String persona;

  const _TypingIndicator({required this.persona});

  String _getPersonaImage(String persona) {
    switch (persona) {
      case 'angry_mom':
        return 'assets/images/finny.png';
      case 'supportive_cheerleader':
        return 'assets/images/mona.png';
      case 'wise_mentor':
        return 'assets/images/vesto.png';
      default:
        return 'assets/images/vesto.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset(
              _getPersonaImage(persona),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.ffb4c2,
                  child: Center(
                    child: Text(
                      '🤖',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: AppColors.ac9780,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final File? selectedImage;
  final bool enabled;

  const _MessageInput({
    required this.controller,
    required this.onSend,
    required this.onPickImage,
    required this.onRemoveImage,
    this.selectedImage,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        border: isDark ? Border(top: BorderSide(color: Colors.grey[700]!, width: 1)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image preview
            if (selectedImage != null) ...[
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.image,
                      size: 16.sp,
                      color: isDark ? Colors.pink[200] : AppColors.b93160,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Gambar terlampir',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.pink[200] : AppColors.b93160,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : AppColors.f4e8da,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.file(
                        selectedImage!,
                        height: 150.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: GestureDetector(
                        onTap: onRemoveImage,
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Input row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Image picker button
                GestureDetector(
                  onTap: enabled ? onPickImage : null,
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : AppColors.f4e8da,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      color: enabled ? (isDark ? Colors.pink[200] : AppColors.b93160) : AppColors.ac9780,
                      size: 24.sp,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(25.r),
                      border: Border.all(
                        color: isDark ? Colors.grey[700]! : AppColors.ac9780.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: controller,
                      enabled: enabled,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.b93160,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : AppColors.ac9780,
                          fontSize: 14.sp,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: enabled ? (_) => onSend() : null,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.linier,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ffb4c2.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: enabled ? onSend : null,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 48.w,
                        height: 48.w,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
