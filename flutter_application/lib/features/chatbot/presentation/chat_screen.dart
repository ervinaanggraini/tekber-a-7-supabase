import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.conversationId != null) {
      context.read<ChatCubit>().openConversation(widget.conversationId!);
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

  void _showPersonaSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.f4e8da,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Asisten AI',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.b93160,
              ),
            ),
            SizedBox(height: 20.h),
            ...ChatPersona.values.map((persona) {
              return _PersonaCard(
                persona: persona,
                onTap: () {
                  Navigator.pop(context);
                  context.read<ChatCubit>().createAndStartConversation(persona);
                },
              );
            }).toList(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.f4e8da,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            if (state is ChatConversationActive) {
              return Row(
                children: [
                  Text(
                    state.conversation.persona.emoji,
                    style: TextStyle(fontSize: 24.sp),
                  ),
                  SizedBox(width: 8.w),
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
                    style: TextStyle(color: AppColors.b93160),
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
                              return _TypingIndicator();
                            }
                            
                            final message = state.messages[index];
                            return _ChatBubble(message: message);
                          },
                        ),
                ),
                _MessageInput(
                  controller: _messageController,
                  onSend: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      context
                          .read<ChatCubit>()
                          .sendMessage(_messageController.text.trim());
                      _messageController.clear();
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
              color: AppColors.b93160,
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              persona.emoji,
              style: TextStyle(fontSize: 80.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'Hai! Aku ${persona.name}',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.b93160,
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
        return 'Aku di sini untuk support kamu! Cerita aja transaksimu, aku siap dengerin dengan senang hati 💖';
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
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
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
                          color: AppColors.b93160,
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

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.ffb4c2,
              child: Text(
                '🤖',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: isUser ? AppColors.linier : null,
                color: isUser ? null : Colors.white,
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
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isUser ? Colors.white : AppColors.b93160,
                ),
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
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16.r,
          backgroundColor: AppColors.ffb4c2,
          child: Text(
            '🤖',
            style: TextStyle(fontSize: 16.sp),
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
  final bool enabled;

  const _MessageInput({
    required this.controller,
    required this.onSend,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.f4e8da,
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: TextField(
                controller: controller,
                enabled: enabled,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  hintStyle: TextStyle(
                    color: AppColors.ac9780,
                    fontSize: 14.sp,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  border: InputBorder.none,
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
    );
  }
}
