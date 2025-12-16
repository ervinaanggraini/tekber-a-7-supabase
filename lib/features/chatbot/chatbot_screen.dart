import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
// TAMBAHKAN IMPORT INI untuk mengakses data source transaksi Anda
import 'package:moneyvesto/data/transaction_datasource.dart';

// Gunakan 10.0.2.2 jika menggunakan Android Emulator
// Gunakan 127.0.0.1 jika menggunakan Windows/Web
const String API_BASE_URL = 'http://127.0.0.1:5000';

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
  String? _selectedPersonalityImagePath;

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
    print("[DEBUG] Menampilkan dialog pemilihan kepribadian.");
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
        print("[DEBUG] Kepribadian dipilih: $displayName ($toneKey)");
        Navigator.of(context).pop();
        setState(() {
          _selectedTone = toneKey;
          _selectedPersonalityImagePath = imagePath;
          final initialMessage =
              'Halo! Aku Vesto, asisten keuangan dengan gaya "$displayName". Siap membantu mencatat keuanganmu!';
          _messages.add({'role': 'bot', 'text': initialMessage});
          print("[DEBUG] Pesan pembuka bot ditambahkan.");
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

  // TAMBAHKAN FUNGSI HELPER INI
  bool _textContainsTransactionIndicators(String text) {
    // Regex ini akan mencari beberapa pola:
    // - Angka diikuti "k", "rb", atau "ribu" (misal: 50k, 100rb, 20 ribu)
    // - "rp" diikuti oleh angka (misal: rp50000, rp 50.000)
    // - Angka yang terdiri dari 4 digit atau lebih (misal: 5000, 15000, 100000)
    final RegExp moneyPattern = RegExp(
      r'(\d+[\.,]?\d*)\s*(k|rb|ribu)|(rp\s*\d+[\.,]?\d*)|\b\d{4,}\b',
      caseSensitive: false,
    );

    final bool hasMatch = moneyPattern.hasMatch(text);
    print("[ROUTING] Pengecekan teks: '$text'. Ditemukan pola uang: $hasMatch");
    return hasMatch;
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
        print("[DEBUG] Gambar dipilih dari ${source.name}: ${pickedFile.path}");
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      } else {
        print("[DEBUG] Pemilihan gambar dibatalkan.");
      }
    } catch (e, s) {
      print("[ERROR] Gagal memilih gambar: $e");
      print("[ERROR] Stack Trace: $s");
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
                  Navigator.pop(context);
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
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // TAMBAHKAN FUNGSI BARU INI
  Future<void> _sendTextToTransactionEndpoint(String text) async {
    print("[API] Teks mengandung uang, merutekan ke /transaction (multipart).");

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$API_BASE_URL/transaction'),
    );

    request.fields['message'] = text;
    request.fields['tone_type'] = _selectedTone!;

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("[API] /transaction (text-only) | Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        await _processBotResponse(decodedResponse);
      } else {
        final errorBody =
            response.body.isNotEmpty
                ? utf8.decode(response.bodyBytes)
                : "No error details";
        _addBotResponse(
          'Gagal memproses transaksi dari teks (Status: ${response.statusCode}).',
        );
        print("[API] Error Body: $errorBody");
      }
    } catch (e, s) {
      print(
        "[API] GAGAL: Exception saat memanggil /transaction (text-only).\nError: $e\nStack Trace: $s",
      );
      _addBotResponse(
        'Terjadi error saat mengirim data transaksi dari teks: $e',
      );
    }
  }


  // GANTI FUNGSI _sendMessage LAMA DENGAN VERSI BARU INI
  Future<void> _sendMessage() async {
    final String text = _controller.text.trim();
    final File? imageFile = _selectedImageFile;

    if (text.isEmpty && imageFile == null) return;
    if (_selectedTone == null) {
      _showPersonalitySelectionDialog();
      return;
    }

    print(
      "[ROUTING] Memulai _sendMessage. Teks: '$text', Ada Gambar: ${imageFile != null}",
    );

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
      // --- LOGIKA PERUTEAN CERDAS DIMULAI DI SINI ---
      if (imageFile != null) {
        // Prioritas 1: Jika ada gambar, selalu gunakan endpoint transaksi gambar.
        print(
          "[ROUTING] Keputusan: Ada gambar. Menggunakan _sendTransactionMessage.",
        );
        await _sendTransactionMessage(imageFile, text);
      } else if (_textContainsTransactionIndicators(text)) {
        // Prioritas 2: Tidak ada gambar, TAPI teks mengandung nominal uang.
        print(
          "[ROUTING] Keputusan: Tidak ada gambar, teks mengandung uang. Menggunakan _sendTextToTransactionEndpoint.",
        );
        await _sendTextToTransactionEndpoint(text);
      } else {
        // Prioritas 3: Teks chat biasa.
        print(
          "[ROUTING] Keputusan: Teks biasa. Menggunakan _sendTextMessage (ke /chat).",
        );
        await _sendTextMessage(text, userMessageMap);
      }
      // --- AKHIR DARI LOGIKA PERUTEAN ---
    } catch (e, s) {
      print(
        "[ERROR] Exception tidak tertangani di _sendMessage: $e\nStack Trace: $s",
      );
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

  // GANTI FUNGSI LAMA DENGAN VERSI SIMPLE INI
  Future<void> _sendTextMessage(
    String text,
    Map<String, dynamic> userMessageMap,
  ) async {
    print("[API] Memulai pengiriman pesan teks ke /chat.");
    List<String> previousChatHistory =
        _messages
            .where((msg) => msg['text'] is String && msg != userMessageMap)
            .map((msg) => "${msg['role']}: ${msg['text'] as String}")
            .toList();

    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': text,
          'previous_chats': previousChatHistory,
        }),
      );
      print("[API] /chat | Respons diterima. Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        // SERAHKAN KE FUNGSI PEMROSES TERPUSAT
        await _processBotResponse(decodedResponse);
      } else {
        final errorBody =
            response.body.isNotEmpty
                ? utf8.decode(response.bodyBytes)
                : "No error details";
        _addBotResponse(
          'Maaf, terjadi kesalahan saat mencoba merespons (Status: ${response.statusCode}).',
        );
      }
    } catch (e, s) {
      print(
        "[API] GAGAL: Exception saat memanggil /chat.\nError: $e\nStack Trace: $s",
      );
      _addBotResponse('Terjadi error saat terhubung ke server chat: $e');
    }
  }

  // GANTI FUNGSI LAMA DENGAN VERSI SIMPLE INI
  Future<void> _sendTransactionMessage(File imageFile, String text) async {
    print("[API] Memulai pengiriman pesan dengan gambar ke /transaction.");
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
      print(
        "[API] /transaction | Respons diterima. Status: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        // SERAHKAN KE FUNGSI PEMROSES TERPUSAT
        await _processBotResponse(decodedResponse);
      } else {
        final errorBody =
            response.body.isNotEmpty
                ? utf8.decode(response.bodyBytes)
                : "No error details";
        _addBotResponse(
          'Gagal memproses gambar (Status: ${response.statusCode} - $errorBody).',
        );
      }
    } catch (e, s) {
      print(
        "[API] GAGAL: Exception saat memanggil /transaction.\nError: $e\nStack Trace: $s",
      );
      _addBotResponse('Terjadi error saat mengirim data: $e');
    }
  }

  String _cleanMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'[#*_~`]'), '')
        .replaceAll(RegExp(r'^\s*(\d+\.|-)\s+', multiLine: true), '');
  }

  // TAMBAHKAN FUNGSI BARU INI
  Future<void> _processBotResponse(Map<String, dynamic> decodedResponse) async {
    print("[PROCESS_RESPONSE] Memulai pemrosesan respons bot.");
    print("[PROCESS_RESPONSE] Data JSON: $decodedResponse");

    // 1. Tampilkan respons teks ke pengguna
    // Logika ini menangani DUA kemungkinan format respons:
    // - Dari /transaction, respons ada di dalam objek 'responses'
    // - Dari /chat, respons ada di kunci 'response'
    String botReply = "Maaf, terjadi kesalahan dalam memahami respons.";
    if (decodedResponse.containsKey('responses') &&
        decodedResponse['responses'] is Map) {
      final Map<String, dynamic> responses = decodedResponse['responses'];
      botReply =
          responses[_selectedTone] ?? "Gagal mendapatkan respons sesuai gaya.";
    } else if (decodedResponse.containsKey('response')) {
      botReply = decodedResponse['response'];
    }
    _addBotResponse(botReply);
    print("[PROCESS_RESPONSE] Teks balasan bot ditampilkan: '$botReply'");

    // 2. SELALU periksa dan simpan data transaksi jika ada
    final List<dynamic>? transactionsData = decodedResponse['transactions'];

    if (transactionsData != null && transactionsData.isNotEmpty) {
      print("[PROCESS_RESPONSE] Data transaksi terdeteksi!");
      final List<Map<String, dynamic>> transactionList =
          transactionsData.cast<Map<String, dynamic>>();

      print("[DB_SAVE] Payload yang akan dikirim: $transactionList");

      try {
        final TransactionDataSource transactionDataSource =
            TransactionDataSourceImpl();
        print("[DB_SAVE] Memanggil transactionDataSource.createTransaction...");
        await transactionDataSource.createTransaction(transactionList);
        print("[DB_SAVE] SUKSES: Transaksi berhasil disimpan ke database!");
        _addBotResponse(
          "Catatan transaksinya juga sudah berhasil disimpan ya!",
        );
      } catch (e, s) {
        print("[DB_SAVE] GAGAL: Gagal menyimpan transaksi ke database.");
        print("[ERROR] Detail Error: $e\nStack Trace: $s");
        _addBotResponse(
          'Aku berhasil mendeteksi transaksi, tapi gagal menyimpannya secara otomatis. Coba lagi atau tambah manual ya.',
        );
      }
    } else {
      print(
        "[PROCESS_RESPONSE] Info: Tidak ada data transaksi ('transactions') yang ditemukan pada respons ini.",
      );
    }
  }

  // GANTI FUNGSI LAMA DENGAN VERSI YANG LEBIH SEDERHANA INI
  void _addBotResponse(String text) {
    // Guard untuk memastikan widget masih ada di tree
    if (!mounted) return;

    print("[UI] Menambahkan respons bot instan ke chat.");

    // Tetap bersihkan teks dari format markdown jika ada
    final String cleanedText = _cleanMarkdown(text);

    // Langsung perbarui state dengan pesan lengkap dari bot
    setState(() {
      _isBotTyping = false;
      _messages.add({'role': 'bot', 'text': cleanedText});
    });

    // Scroll ke bawah setelah pesan baru ditambahkan
    _scrollToBottom();

    print("[UI] Pesan bot ditambahkan: '$cleanedText'");
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

  // SISA KODE (WIDGET BUILD) TIDAK PERLU DIUBAH
  // Salin dan tempel sisa kode Anda dari sini
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
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
