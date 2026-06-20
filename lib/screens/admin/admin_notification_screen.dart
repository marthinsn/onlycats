import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../services/notification_service.dart';
import 'admin_adoptions_screen.dart';
import 'admin_chat_detail_screen.dart';
import 'admin_rescue_screen.dart';

class AdminNotificationScreen extends StatelessWidget {
  const AdminNotificationScreen({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> _adminNotificationStream() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: 'admin')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  String _formatTime(dynamic createdAt) {
    if (createdAt == null) return '-';
    DateTime dateTime;
    if (createdAt is Timestamp) {
      dateTime = createdAt.toDate();
    } else if (createdAt is String) {
      dateTime = DateTime.tryParse(createdAt) ?? DateTime.now();
    } else {
      dateTime = DateTime.now();
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inMinutes < 60) return '${difference.inMinutes} menit lalu';
    if (difference.inHours < 24) return '${difference.inHours} jam lalu';
    if (difference.inDays == 1) return 'Kemarin';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'rescue_submit_admin':
        return Icons.warning_amber_rounded;
      case 'adoption_submit_admin':
        return Icons.favorite_border;
      case 'chat_receive_admin':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'rescue_submit_admin':
        return AppColors.danger;
      case 'adoption_submit_admin':
        return AppColors.orange;
      case 'chat_receive_admin':
        return Colors.blue;
      default:
        return AppColors.primaryText;
    }
  }

  String _extractChatUserNameFromTitle(String title) {
    const prefix = 'Pesan Baru dari ';
    if (!title.startsWith(prefix)) return '';

    return title
        .substring(prefix.length)
        .replaceAll('💬', '')
        .trim()
        .toLowerCase();
  }

  Future<String> _findChatUserIdFromNotification(
    Map<String, dynamic> notificationData,
  ) async {
    final chatUserId = notificationData['chatUserId']?.toString() ?? '';
    if (chatUserId.trim().isNotEmpty) return chatUserId.trim();

    final titleName = _extractChatUserNameFromTitle(
      notificationData['title']?.toString() ?? '',
    );
    if (titleName.isEmpty) return '';

    final rooms = await FirebaseFirestore.instance
        .collection('chat_rooms')
        .get();

    for (final room in rooms.docs) {
      final data = room.data();
      final roomUserName = data['userName']?.toString().trim().toLowerCase();
      if (roomUserName == titleName) {
        return room.id;
      }
    }

    return '';
  }

  Future<void> _markChatNotificationsAsRead(
    String chatUserId,
    String chatUserName,
  ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: 'admin')
        .where('isRead', isEqualTo: false)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    var hasUpdates = false;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['type'] != 'chat_receive_admin') continue;

      final docChatUserId = data['chatUserId']?.toString() ?? '';
      final docTitleUserName = _extractChatUserNameFromTitle(
        data['title']?.toString() ?? '',
      );

      if (docChatUserId == chatUserId ||
          (docChatUserId.isEmpty && docTitleUserName == chatUserName)) {
        batch.update(doc.reference, {'isRead': true, 'chatUserId': chatUserId});
        hasUpdates = true;
      }
    }

    if (hasUpdates) {
      await batch.commit();
    }
  }

  Future<String> _getChatUserName(
    String chatUserId,
    Map<String, dynamic> notificationData,
  ) async {
    final roomDoc = await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatUserId)
        .get();

    final roomData = roomDoc.data();
    final roomUserName = roomData?['userName']?.toString();
    if (roomUserName != null && roomUserName.trim().isNotEmpty) {
      return roomUserName;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(chatUserId)
        .get();

    final userData = userDoc.data();
    final userName = userData?['username']?.toString();
    if (userName != null && userName.trim().isNotEmpty) {
      return userName;
    }

    return notificationData['title']?.toString() ?? 'User';
  }

  Future<void> _handleNotificationTap(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> notificationDoc,
  ) async {
    final data = notificationDoc.data();
    final type = data['type']?.toString() ?? '';
    final isRead = data['isRead'] == true;

    if (type == 'chat_receive_admin') {
      final chatUserId = await _findChatUserIdFromNotification(data);

      if (chatUserId.isEmpty) {
        if (!isRead) {
          await NotificationService().markAsRead(notificationDoc.id);
        }

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room chat untuk notifikasi ini tidak ditemukan.'),
          ),
        );
        return;
      }

      final userName = await _getChatUserName(chatUserId, data);
      await _markChatNotificationsAsRead(chatUserId, userName.toLowerCase());

      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AdminChatDetailScreen(userId: chatUserId, userName: userName),
        ),
      );
      return;
    }

    if (!isRead) {
      await NotificationService().markAsRead(notificationDoc.id);
    }

    if (!context.mounted) return;

    if (type == 'rescue_submit_admin') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminRescueScreen()),
      );
    } else if (type == 'adoption_submit_admin') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminAdoptionsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifikasi Admin',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.primaryText,
        actions: [
          TextButton(
            onPressed: () => NotificationService().markAllAsRead('admin'),
            child: const Text('Tandai Semua'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _adminNotificationStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada notifikasi baru',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final isRead = data['isRead'] == true;
              final type = data['type'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isRead ? Colors.white : const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isRead ? Colors.grey[200]! : Colors.blue[100]!,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getColor(type).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getIcon(type), color: _getColor(type)),
                  ),
                  title: Text(
                    data['title'] ?? 'Notifikasi',
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        data['message'] ?? '',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(data['createdAt']),
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                  onTap: () => _handleNotificationTap(context, docs[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
