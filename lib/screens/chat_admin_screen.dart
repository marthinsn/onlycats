import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';

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
  bool _isLiveChat = false; // Flag untuk mode live chat

  final String _apiKey =
      "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";
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  String _actualUserName = "User";

  // Pastel Color Palette
  final Color _bgColor = const Color(0xFFFDF6F0);
  final Color _botBubbleColor = Colors.white;
  final Color _userBubbleColor = const Color(0xFFFFE5D9);
  final Color _adminBubbleColor = const Color(0xFFD0E1F9);
  final Color _accentColor = const Color(0xFFFF9B71);
  final Color _textColor = const Color(0xFF4A4A4A);

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
        setState(() {
          _actualUserName = doc.data()?['username'] ?? "User";
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
        // Inisialisasi room chat di Firestore jika belum ada
        await FirebaseFirestore.instance
            .collection('chat_rooms')
            .doc(_userId)
            .set({
          'userId': _userId,
          'userName': _actualUserName,
          'lastMessage': 'Menunggu admin...',
          'timestamp': FieldValue.serverTimestamp(),
          'unreadByAdmin': true,
        }, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Terhubung ke Live Chat Admin')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal terhubung: $e')),
        );
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

    // Ensure we have the latest username
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
      // Build conversation history for API
      List<Map<String, String>> messages = [
        {
          'role': 'system',
          'content': 'Anda adalah asisten chatbot ahli kucing untuk aplikasi OnlyCats. '
              'Ikuti aturan ini dalam menjawab: '
              '1. Hanya fokus pada topik kucing. '
              '2. Jika user bertanya mengenai cara melakukan penyelamatan (rescue) kucing melalui aplikasi, jelaskan tahapan berikut dengan bahasa yang sangat profesional: '
              '   a. Navigasi ke tab "Rescue". b. Klik tombol Laporan Rescue baru. c. Unggah foto kondisi kucing. d. Tentukan lokasi pada peta. e. Pilih kondisi umum kucing. f. Berikan deskripsi detail. g. Masukkan nomor telepon. h. Tambahkan catatan (opsional). i. Pantau status (Menunggu/Diproses/Selesai) di riwayat laporan. '
              '3. Jika user bertanya mengenai tata cara adopsi kucing, sampaikan langkah berikut: '
              '   a. Pilih kucing di menu utama. b. Pelajari deskripsi. c. Klik "Ajukan Adopsi". d. Isi form data diri, tempat tinggal, alasan adopsi, dan pengalaman. e. Klik "Kirim Form Adopsi". f. Pantau status di halaman "Adopsi". '
              '4. Jika user memberikan keluhan kesehatan/perawatan, lakukan verifikasi dengan menanyakan 1-3 pertanyaan detail yang relevan (seperti keparahan, gejala lain, atau riwayat kucing). '
              '5. JANGAN mengulang pertanyaan yang sudah dijawab oleh user. Perhatikan riwayat chat dengan saksama. '
              '6. Jika user sudah memberikan detail yang cukup atau menjawab pertanyaan verifikasi Anda, segera berikan kesimpulan, saran, atau solusi yang praktis. '
              '7. Gunakan bahasa yang ramah, profesional, dan suportif.'
        }
      ];

      // Add previous messages to history (limit to last 10 to save tokens/context)
      for (var msg in _aiMessages.reversed.take(10).toList().reversed) {
        messages.add({
          'role': msg['isUser'] ? 'user' : 'assistant',
          'content': msg['text'],
        });
      }

      final response = await http.post(
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
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = data['choices'][0]['message']['content'];
        setState(() {
          _aiMessages.add({
            'text': botResponse ?? 'Maaf, saya sedang bingung.',
            'isUser': false,
          });
        });
      }
    } catch (e) {
      setState(() {
        _aiMessages.add({'text': 'Terjadi kesalahan: $e', 'isUser': false});
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _textColor,
        title: Text(
          _isLiveChat ? 'Live Chat Admin' : 'OnlyCats AI',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          _isLiveChat
              ? TextButton.icon(
                  onPressed: _toggleLiveChat,
                  icon: const Icon(
                    Icons.smart_toy_outlined,
                    size: 20,
                    color: Color(0xFFFF9B71),
                  ),
                  label: const Text(
                    'Back to AI',
                    style: TextStyle(
                      color: Color(0xFFFF9B71),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : TextButton.icon(
                  onPressed: _toggleLiveChat,
                  icon: const Icon(
                    Icons.support_agent,
                    size: 20,
                    color: Color(0xFFFF9B71),
                  ),
                  label: const Text(
                    'Hubungi Admin',
                    style: TextStyle(
                      color: Color(0xFFFF9B71),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ],
      ),
      body: Column(
        children: [
          if (_isLiveChat)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: _adminBubbleColor.withOpacity(0.5),
              child: const Text(
                'Anda sedang berbicara dengan Admin',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          Expanded(
            child: _isLiveChat ? _buildLiveChatList() : _buildAiChatList(),
          ),
          if (!_isLiveChat && _isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'OnlyCats AI sedang mengetik...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildAiChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline,
                    size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text(
                  'Mulai percakapan dengan admin',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Auto scroll to bottom when new messages arrive
        _scrollToBottom();

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
    Color bubbleColor = _botBubbleColor;
    if (isUser) bubbleColor = _userBubbleColor;
    if (isAdmin) bubbleColor = _adminBubbleColor;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: _textColor, fontSize: 15, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Tulis pesan...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) =>
                    _isLiveChat ? _sendLiveMessage() : _sendAiMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _isLiveChat ? _sendLiveMessage() : _sendAiMessage(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _accentColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
