import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

@override
  void initState() {
    super.initState();

    // Tambahkan pesan sambutan setelah build selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _messages.add({
          'role': 'bot',
          'text':
              'Halo! Aku **Vesto**, asisten keuangan pribadimu. Yuk, ngobrol soal keuangan, budgeting, atau tips menabung!',
        });
      });
    });
  }


  void _addWelcomeMessage() {
    _messages.add({
      'role': 'bot',
      'text':
          'Halo! Aku Vesto, asisten keuangan pribadimu. Yuk, ngobrol soal keuangan, budgeting, atau tips menabung!',
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _messages.add({
        'role': 'bot',
        'text': 'Hai! Ini adalah respon sementara dari chatbot.',
      });
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002366),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002366),
        elevation: 0,
        centerTitle: true,
        title: GlobalText.medium(
          'Vesto!',
          fontSize: 18.sp,
          color: Colors.white,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    constraints: BoxConstraints(maxWidth: 250.w),
                    decoration: BoxDecoration(
                      color:
                          isUser
                              ? Colors.blueAccent
                              : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.r),
                        topRight: Radius.circular(12.r),
                        bottomLeft: Radius.circular(isUser ? 12.r : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 12.r),
                      ),
                    ),
                    child: GlobalText.regular(
                      message['text'] ?? '',
                      color: Colors.white,
                      fontSize: 14.sp,
                      textAlign: isUser ? TextAlign.right : TextAlign.left,
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Colors.white24),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Tulis pesan...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
