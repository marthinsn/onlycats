import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../services/notification_service.dart';

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
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    if (!isRead) {
                      NotificationService().markAsRead(docs[index].id);
                    }
                    // TODO: Navigasi detail berdasarkan type jika diperlukan
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
