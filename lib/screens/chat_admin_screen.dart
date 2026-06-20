import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../widgets/cat_loading.dart';
import '../services/admin_service.dart';
import '../services/notification_service.dart';

class ChatAdminScreen extends StatefulWidget {
  const ChatAdminScreen({super.key});

  @override
  State<ChatAdminScreen> createState() => _ChatAdminScreenState();
}

class _ChatAdminScreenState extends State<ChatAdminScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _aiMessages = [];
  bool _isLoading = false;
  bool _isLiveChat = false;

  String get _apiKey =>
      "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";
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  String _actualUserName = "User";

  // Modern Palette
  final Color _bgColor = const Color(0xFFF8F9FB);
  final Color _botBubbleColor = Colors.white;
  final Color _userBubbleColor = const Color(0xFFFF9B71);
  final Color _adminBubbleColor = const Color(0xFF3D5A80);
  final Color _accentColor = const Color(0xFFFF9B71);
  final Color _textColor = const Color(0xFF20223A);

  @override
  void initState() {
    super.initState();
    _aiMessages.add({
      'text':
          'Halo! Saya asisten OnlyCats. Ada yang bisa saya bantu seputar kucing kesayanganmu hari ini? 🐾',
      'isUser': false,
    });
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (_userId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();
      if (doc.exists) {
        if (mounted) {
          setState(() {
            _actualUserName = doc.data()?['username'] ?? "User";
          });
        }
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // --- LOGIC LIVE CHAT ---

  void _toggleLiveChat() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    try {
      setState(() {
        _isLiveChat = !_isLiveChat;
      });

      if (_isLiveChat) {
        // Cek dulu apakah room sudah ada
        final roomDoc = await FirebaseFirestore.instance
            .collection('chat_rooms')
            .doc(_userId)
            .get();

        if (!roomDoc.exists) {
          // Jika belum ada, buat room baru dengan data minimal
          // tapi jangan set 'unreadByAdmin' true dulu agar tidak muncul notif kosong
          await FirebaseFirestore.instance
              .collection('chat_rooms')
              .doc(_userId)
              .set({
                'userId': _userId,
                'userName': _actualUserName,
                'lastMessage': '',
                'timestamp': FieldValue.serverTimestamp(),
                'unreadByAdmin': false,
              });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Terhubung ke Live Chat Admin'),
              backgroundColor: Color(0xFF3D5A80),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal terhubung: $e')));
      }
      setState(() {
        _isLiveChat = false;
      });
    }
  }

  Future<void> _sendLiveMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _userId == null) return;

    _messageController.clear();
    await _fetchUserData();

    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(_userId)
        .collection('messages')
        .add({
          'senderId': _userId,
          'text': text,
          'timestamp': FieldValue.serverTimestamp(),
          'isUser': true,
        });

    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(_userId)
        .update({
          'userId': _userId,
          'userName': _actualUserName,
          'lastMessage': text,
          'timestamp': FieldValue.serverTimestamp(),
          'unreadByAdmin': true,
        });

    // NOTIF UNTUK ADMIN
    await NotificationService().createNotification(
      userId: 'admin',
      title: 'Pesan Baru dari $_actualUserName 💬',
      message: text,
      type: 'chat_receive_admin',
    );

    _scrollToBottom();
  }

  // --- LOGIC AI CHAT ---

  Future<void> _sendAiMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _aiMessages.add({'text': text, 'isUser': true});
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      List<Map<String, String>> messages = [
        {
          'role': 'system',
          'content':
              'Anda adalah asisten chatbot ahli kucing untuk aplikasi OnlyCats. '
              'Ikuti aturan ini dalam menjawab: '
              '1. Hanya fokus pada topik kucing. '
              '2. Jika user bertanya mengenai cara melakukan penyelamatan (rescue) kucing melalui aplikasi, jelaskan tahapan berikut dengan bahasa yang sangat profesional: '
              '   a. Navigasi ke tab "Rescue". b. Klik tombol Laporan Rescue baru. c. Unggah foto kondisi kucing. d. Tentukan lokasi pada peta. e. Pilih kondisi umum kucing. f. Berikan deskripsi detail. g. Masukkan nomor telepon. h. Tambahkan catatan (opsional). i. Pantau status (Menunggu/Diproses/Selesai) di riwayat laporan. '
              '3. Jika user bertanya mengenai tata cara adopsi kucing, sampaikan langkah berikut: '
              '   a. Pilih kucing di menu utama. b. Pelajari deskripsi. c. Klik "Ajukan Adopsi". d. Isi form data diri, tempat tinggal, alasan adopsi, dan pengalaman. e. Klik "Kirim Form Adopsi". f. Pantau status di halaman "Adopsi". '
              '4. Jika user memberikan keluhan kesehatan/perawatan, lakukan verifikasi dengan menanyakan 1-3 pertanyaan detail yang relevan (seperti keparahan, gejala lain, atau riwayat kucing). '
              '5. JANGAN mengulang pertanyaan yang sudah dijawab oleh user. Perhatikan riwayat chat dengan saksama. '
              '6. Jika user sudah memberikan detail yang cukup atau menjawab pertanyaan verifikasi Anda, segera berikan kesimpulan, saran, atau solusi yang praktis. '
              '7. Gunakan bahasa yang ramah, profesional, dan suportif.',
        },
      ];

      for (var msg in _aiMessages.reversed.take(10).toList().reversed) {
        messages.add({
          'role': msg['isUser'] ? 'user' : 'assistant',
          'content': msg['text'],
        });
      }

      final response = await http
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': 'llama-3.3-70b-versatile',
              'messages': messages,
              'temperature': 0.7,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = data['choices'][0]['message']['content'];
        setState(() {
          _aiMessages.add({
            'text': botResponse ?? 'Maaf, saya sedang bingung.',
            'isUser': false,
          });
        });
      } else {
        setState(() {
          _aiMessages.add({
            'text': _buildAiErrorMessage(response),
            'isUser': false,
          });
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiMessages.add({'text': 'Terjadi kesalahan: $e', 'isUser': false});
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  String _buildAiErrorMessage(http.Response response) {
    var detail = response.body;

    try {
      final decoded = jsonDecode(response.body);
      final message = decoded['error']?['message'];
      if (message is String && message.trim().isNotEmpty) {
        detail = message;
      }
    } catch (_) {
      // Keep raw response body if Groq does not return JSON.
    }

    switch (response.statusCode) {
      case 400:
        return 'AI belum bisa merespon karena request tidak valid: $detail';
      case 401:
      case 403:
        return 'AI belum bisa merespon. Status ${response.statusCode}: $detail';
      case 429:
        return 'AI sedang terkena batas pemakaian. Coba lagi beberapa saat lagi.';
      default:
        return 'AI belum bisa merespon. Server mengembalikan status ${response.statusCode}: $detail';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        foregroundColor: _textColor,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isLiveChat
                    ? const Color(0xFF3D5A80).withOpacity(0.1)
                    : const Color(0xFFFF9B71).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isLiveChat
                    ? Icons.support_agent_rounded
                    : Icons.smart_toy_rounded,
                color: _isLiveChat
                    ? const Color(0xFF3D5A80)
                    : const Color(0xFFFF9B71),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLiveChat ? 'Admin OnlyCats' : 'OnlyCats AI',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                if (_isLiveChat)
                  StreamBuilder<bool>(
                    stream: AdminService().streamAdminStatus(),
                    builder: (context, snapshot) {
                      final isOnline = snapshot.data ?? false;
                      if (!isOnline) return const SizedBox.shrink();

                      return Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      );
                    },
                  )
                else
                  const Text(
                    'Aktif',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.orange,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ActionChip(
              onPressed: _toggleLiveChat,
              backgroundColor: _isLiveChat
                  ? const Color(0xFFF3ECE8)
                  : const Color(0xFF3D5A80),
              label: Text(
                _isLiveChat ? 'Pindah ke AI' : 'Live Chat',
                style: TextStyle(
                  color: _isLiveChat ? AppColors.primaryText : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              avatar: Icon(
                _isLiveChat
                    ? Icons.psychology_rounded
                    : Icons.headset_mic_rounded,
                size: 16,
                color: _isLiveChat ? AppColors.orange : Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _bgColor,
                image: DecorationImage(
                  image: const NetworkImage(
                    'https://www.transparenttextures.com/patterns/cubes.png',
                  ),
                  opacity: 0.03,
                  colorFilter: ColorFilter.mode(
                    _textColor.withOpacity(0.1),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              child: _isLiveChat ? _buildLiveChatList() : _buildAiChatList(),
            ),
          ),
          if (!_isLiveChat && _isLoading) _buildTypingIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.orange,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'AI sedang merangkai kata...',
            style: TextStyle(
              fontSize: 11,
              color: _textColor.withOpacity(0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiChatList() {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      itemCount: _aiMessages.length,
      itemBuilder: (context, index) {
        final msg = _aiMessages[index];
        return _buildMessageBubble(msg['text'], msg['isUser'], false);
      },
    );
  }

  Widget _buildLiveChatList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(_userId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CatLoading());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.forum_outlined,
                    size: 48,
                    color: Color(0xFF3D5A80),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Halo! Ingin bertanya langsung ke admin?',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ketik pesanmu di bawah ya.',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        _scrollToBottom();

        return ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _buildMessageBubble(
              data['text'] ?? '',
              data['isUser'] ?? true,
              !(data['isUser'] ?? true),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, bool isAdmin) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? _userBubbleColor
                  : (isAdmin ? _adminBubbleColor : _botBubbleColor),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(24),
                topRight: const Radius.circular(24),
                bottomLeft: Radius.circular(isUser ? 24 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isUser || isAdmin ? Colors.white : _textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  hintText: 'Tulis sesuatu...',
                  hintStyle: TextStyle(color: Color(0xFFADB3BC)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) =>
                    _isLiveChat ? _sendLiveMessage() : _sendAiMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _isLiveChat ? _sendLiveMessage() : _sendAiMessage(),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isLiveChat
                      ? [const Color(0xFF3D5A80), const Color(0xFF203554)]
                      : [const Color(0xFFFF9B71), const Color(0xFFFF7A3D)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        (_isLiveChat ? const Color(0xFF3D5A80) : _accentColor)
                            .withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
