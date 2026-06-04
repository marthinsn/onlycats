import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../theme/app_colors.dart';
import '../../services/notification_service.dart';
import 'admin_bottom_nav.dart';
import '../notification_screen.dart'; // reuse NotificationItemCard

class AdminNotificationScreen extends StatelessWidget {
  const AdminNotificationScreen({super.key});

  static const Color adminBlue = Color(0xFF203554);
  static const Color adminBlueBg = Color(0xFFE8EDF4);
  static const Color adminBlueBorder = Color(0xFFCDD5E0);

  Stream<QuerySnapshot<Map<String, dynamic>>> _notificationStream(
    String userId,
  ) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _markAllAsRead(BuildContext context, String userId) async {
    try {
      await NotificationService().markAllAsRead(userId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua notifikasi sudah ditandai dibaca.'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menandai notifikasi: $e')));
    }
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
      case 'rescue_submit':
        return Icons.warning_amber_rounded;
      case 'rescue_status':
        return Icons.access_time;
      case 'rescue_done':
        return Icons.check_circle_outline;
      case 'adoption':
        return Icons.favorite_border;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  String _getChipLabel(String type) {
    switch (type) {
      case 'rescue_submit':
        return 'Rescue';
      case 'rescue_status':
        return 'Update';
      case 'rescue_done':
        return 'Selesai';
      case 'adoption':
        return 'Adopsi';
      default:
        return 'Info';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Tidak ada sesi login.')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _notificationStream(user.uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Gagal memuat notifikasi: ${snapshot.error}'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: adminBlue),
              );
            }

            final docs = snapshot.data?.docs ?? [];
            final unreadCount = docs
                .where((d) => d.data()['isRead'] == false)
                .length;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(context, user.uid, unreadCount),
                  const SizedBox(height: 14),
                  const Text(
                    'Lihat update rescue, adopsi, dan aktivitas akunmu.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildSummaryCard(unreadCount),
                  const SizedBox(height: 26),
                  const Text(
                    'NOTIFIKASI',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Color(0xFFB5AAA5),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (docs.isEmpty)
                    _buildEmpty()
                  else
                    ...docs.map((doc) {
                      final data = doc.data();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _AdminNotificationCard(
                          icon: _getIcon(data['type'] ?? ''),
                          title: data['title'] ?? 'Notifikasi',
                          message: data['message'] ?? '-',
                          timeText: _formatTime(data['createdAt']),
                          chipLabel: _getChipLabel(data['type'] ?? ''),
                          showDot: data['isRead'] != true,
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, String userId, int unreadCount) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: adminBlueBg,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: adminBlue,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text(
            'Notifikasi',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
            ),
          ),
        ),
        OutlinedButton(
          onPressed: unreadCount == 0
              ? null
              : () => _markAllAsRead(context, userId),
          style: OutlinedButton.styleFrom(
            foregroundColor: adminBlue,
            side: const BorderSide(color: adminBlueBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          child: const Text(
            'Tandai semua',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(int unreadCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: adminBlueBg,
        border: Border.all(color: adminBlueBorder),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: adminBlue,
            child: Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$unreadCount notifikasi baru',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ada update penting tentang rescue dan aktivitas akunmu.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: adminBlueBg,
        border: Border.all(color: adminBlueBorder),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        children: [
          Icon(Icons.notifications_off_outlined, color: adminBlue, size: 42),
          SizedBox(height: 12),
          Text(
            'Belum ada notifikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Update rescue kamu akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

// Card notifikasi versi admin (biru)
class _AdminNotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String timeText;
  final String chipLabel;
  final bool showDot;

  const _AdminNotificationCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.timeText,
    required this.chipLabel,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        border: Border.all(color: const Color(0xFFCDD5E0)),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDF4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: const Color(0xFF203554), size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeText,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFA2A0B0),
                      ),
                    ),
                    if (showDot) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF203554),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCDD5E0)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    chipLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF203554),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
