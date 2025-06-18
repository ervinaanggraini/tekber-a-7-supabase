import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:moneyvesto/core/constants/color.dart'; // Pastikan path ini benar
import 'package:moneyvesto/core/global_components/global_text.dart'; // Pastikan path ini benar

const String API_BASE_URL = 'http://45.13.132.219:6677';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isBotTyping = false;
  File? _selectedImageFile;

  String? _selectedTone;
  String? _selectedPersonalityImagePath; // State untuk path gambar kepribadian

  final Map<String, String> _toneDisplayNames = {
    'supportive_cheerleader': 'Penyemangat Baik Hati',
    'angry_mom': 'Ibu-Ibu Khawatir',
    'wise_mentor': 'Mentor Bijak',
  };

  final Map<String, String> _personalityImages = {
    'supportive_cheerleader': 'assets/images/supportive_cheerleader.png',
    'angry_mom': 'assets/images/angry-mom.png',
    'wise_mentor': 'assets/images/wise-mentor.png',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showPersonalitySelectionDialog();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _showPersonalitySelectionDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Center(
            child: GlobalText.medium(
              'Pilih Kepribadian Vesto',
              color: AppColors.textLight,
              fontSize: 18.sp,
            ),
          ),
          content: SingleChildScrollView(
            child: Wrap(
              // MENGGUNAKAN WRAP UNTUK MENGHINDARI OVERFLOW
              alignment: WrapAlignment.center,
              spacing: 16.w,
              runSpacing: 16.h,
              children:
                  _toneDisplayNames.keys.map((toneKey) {
                    return _buildPersonalityChoice(
                      context: context,
                      toneKey: toneKey,
                      imagePath: _personalityImages[toneKey]!,
                      displayName: _toneDisplayNames[toneKey]!,
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPersonalityChoice({
    required BuildContext context,
    required String toneKey,
    required String imagePath,
    required String displayName,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        setState(() {
          _selectedTone = toneKey;
          _selectedPersonalityImagePath = imagePath; // SIMPAN PATH GAMBAR
          _messages.add({
            'role': 'bot',
            'text':
                'Halo! Aku Vesto, asisten keuangan dengan gaya "$displayName". Siap membantu mencatat keuanganmu!',
          });
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            width: 80.w,
            height: 80.w,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.person, size: 80.w, color: AppColors.textLight);
            },
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: 85.w,
            child: GlobalText.regular(
              displayName,
              color: AppColors.textLight,
              fontSize: 14.sp,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      if (mounted) {
        Get.snackbar(
          'Error',
          'Gagal memilih gambar: ${e.toString()}',
          backgroundColor: AppColors.danger,
          colorText: AppColors.textLight,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondaryAccent,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.textLight,
                ),
                title: GlobalText.regular(
                  'Galeri Foto',
                  color: AppColors.textLight,
                ),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.textLight,
                ),
                title: GlobalText.regular('Kamera', color: AppColors.textLight),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendMessage() async {
    final String text = _controller.text.trim();
    final File? imageFile = _selectedImageFile;

    if (text.isEmpty && imageFile == null) return;
    if (_selectedTone == null) {
      _showPersonalitySelectionDialog();
      return;
    }

    Map<String, dynamic> userMessageMap = {
      'role': 'user',
      'text': text.isEmpty && imageFile != null ? "Ini nota/struknya" : text,
      if (imageFile != null) 'image_path': imageFile.path,
    };

    if (mounted) {
      setState(() {
        _messages.add(userMessageMap);
        _isBotTyping = true;
        _selectedImageFile = null;
      });
      _scrollToBottom();
    }
    _controller.clear();

    try {
      if (imageFile != null) {
        await _sendTransactionMessage(imageFile, text);
      } else {
        await _sendTextMessage(text, userMessageMap);
      }
    } catch (e, s) {
      print('Error sending message: $e\n$s');
      if (mounted) {
        _addBotResponse(
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBotTyping = false);
        _scrollToBottom();
      }
    }
  }

  Future<void> _sendTextMessage(
    String text,
    Map<String, dynamic> userMessageMap,
  ) async {
    List<String> previousChatHistory =
        _messages
            .where((msg) => msg['text'] is String && msg != userMessageMap)
            .map((msg) => msg['text'] as String)
            .toList();

    final response = await http.post(
      Uri.parse('$API_BASE_URL/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': text,
        'previous_chats': previousChatHistory,
      }),
    );

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      _addBotResponse(
        decodedResponse['response'] ?? 'Maaf, saya tidak mengerti responsnya.',
      );
    } else {
      final errorBody =
          response.body.isNotEmpty ? response.body : "No error details";
      _addBotResponse(
        'Maaf, terjadi kesalahan (Status: ${response.statusCode} - $errorBody).',
      );
    }
  }

  Future<void> _sendTransactionMessage(File imageFile, String text) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$API_BASE_URL/transaction'),
    );
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );
    request.fields['tone_type'] = _selectedTone!;
    if (text.isNotEmpty) {
      request.fields['message'] = text;
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final Map<String, dynamic>? responses = decodedResponse['responses'];
        final String personalityResponse =
            responses?[_selectedTone] ??
            "Gagal mendapatkan respons dari server.";
        _addBotResponse(personalityResponse);
      } else {
        final errorBody =
            response.body.isNotEmpty
                ? utf8.decode(response.bodyBytes)
                : "No error details";
        _addBotResponse(
          'Gagal memproses gambar (Status: ${response.statusCode} - $errorBody).',
        );
      }
    } catch (e) {
      _addBotResponse('Terjadi error saat mengirim data: $e');
    }
  }

  String _cleanMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'[#*_~`]'), '')
        .replaceAll(RegExp(r'^\s*(\d+\.|-)\s+', multiLine: true), '');
  }

  void _addBotResponse(String text) {
    if (!mounted) return;

    final String cleanedText = _cleanMarkdown(text);
    setState(() {
      _isBotTyping = false;
      _messages.add({'role': 'bot', 'text': ''});
    });
    _scrollToBottom();
    int charIndex = 0;
    Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (mounted) {
        if (charIndex < cleanedText.length) {
          setState(() {
            _messages.last['text'] =
                _messages.last['text']! + cleanedText[charIndex];
            _scrollToBottom();
          });
          charIndex++;
        } else {
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  Widget _buildMessageItem(Map<String, dynamic> message, int index) {
    if (message['role'] == 'bot_typing') {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 6.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.secondaryAccent,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: GlobalText.regular(
            "Vesto sedang mengetik...",
            color: AppColors.textLight.withOpacity(0.7),
            fontSize: 14.sp,
          ),
        ),
      );
    }

    final isUser = message['role'] == 'user';
    final String? textContent = message['text'] as String?;
    final String? imagePath = message['image_path'] as String?;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryAccent : AppColors.secondaryAccent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isUser ? 16.r : 4.r),
            bottomRight: Radius.circular(isUser ? 4.r : 16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagePath != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.file(File(imagePath)),
                ),
              ),
            if (textContent != null && textContent.isNotEmpty)
              GlobalText.regular(
                textContent,
                color: AppColors.textLight,
                fontSize: 14.sp,
                textAlign: TextAlign.start,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: GlobalText.medium(
          'Vesto!',
          fontSize: 18.sp,
          color: AppColors.textLight,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textLight,
            size: 20.sp,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // MENAMPILKAN GAMBAR VESTO SETELAH DIPILIH
          if (_selectedPersonalityImagePath != null)
            Padding(
              padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
              child: Center(
                child: SizedBox(
                  width: 80.w,
                  height: 80.w,
                  child: ClipOval(
                    child: Image.asset(
                      _selectedPersonalityImagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 80.w,
                          color: AppColors.textLight,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: _messages.length + (_isBotTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isBotTyping && index == _messages.length) {
                  return _buildMessageItem({'role': 'bot_typing'}, index);
                }
                return _buildMessageItem(_messages[index], index);
              },
            ),
          ),
          if (_selectedImageFile != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              color: AppColors.secondaryAccent.withOpacity(0.85),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: Image.file(
                      _selectedImageFile!,
                      width: 48.w,
                      height: 48.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GlobalText.regular(
                      _selectedImageFile!.path.split('/').last,
                      color: AppColors.textLight.withOpacity(0.9),
                      fontSize: 13.sp,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.textLight.withOpacity(0.7),
                      size: 22.sp,
                    ),
                    onPressed: () => setState(() => _selectedImageFile = null),
                  ),
                ],
              ),
            ),
          Divider(height: 1, color: AppColors.textLight.withOpacity(0.15)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            color: AppColors.secondaryAccent,
            child: SafeArea(
              top: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.attach_file_rounded,
                      color: AppColors.textLight.withOpacity(0.8),
                      size: 24.sp,
                    ),
                    onPressed: () => _showImageSourceActionSheet(context),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            _selectedImageFile == null
                                ? 'Tulis pesan...'
                                : 'Tambah deskripsi...',
                        hintStyle: TextStyle(
                          color: AppColors.textLight.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 8.w,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      textInputAction: TextInputAction.send,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: AppColors.primaryAccent,
                      size: 24.sp,
                    ),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
