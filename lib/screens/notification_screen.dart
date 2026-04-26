import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_colors.dart';
import '../services/notification_service.dart';
import 'home_screen.dart';
import 'rescue_screen.dart';
import 'profile_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

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

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
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
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: const Text('Silakan login terlebih dahulu.'),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNavigation(context),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _notificationStream(user.uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Gagal memuat notifikasi: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.orange),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            final unreadCount = docs.where((doc) {
              final data = doc.data();
              return data['isRead'] == false;
            }).length;

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
                    _buildEmptyNotification()
                  else
                    ...docs.map((doc) {
                      final data = doc.data();

                      final title = data['title'] ?? 'Notifikasi';
                      final message = data['message'] ?? '-';
                      final type = data['type'] ?? 'info';
                      final isRead = data['isRead'] == true;
                      final createdAt = data['createdAt'];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: NotificationItemCard(
                          icon: _getIcon(type),
                          title: title,
                          message: message,
                          timeText: _formatTime(createdAt),
                          chipLabel: _getChipLabel(type),
                          showDot: !isRead,
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
              border: Border.all(color: const Color(0xFFFFD0BE)),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryText,
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
              : () {
                  _markAllAsRead(context, userId);
                },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.orange,
            side: const BorderSide(color: Color(0xFFFFD0BE)),
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
        color: const Color(0xFFFFFAF8),
        border: Border.all(color: const Color(0xFFFFD0BE)),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.orange,
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

  Widget _buildEmptyNotification() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF8),
        border: Border.all(color: const Color(0xFFFFD0BE)),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.notifications_off_outlined,
            color: AppColors.orange,
            size: 42,
          ),
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

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      height: 84,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE9E4E1))),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RescueScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
        },
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: AppColors.orange,
        unselectedItemColor: AppColors.iconGrey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.change_history_outlined),
            label: 'Rescue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class NotificationItemCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String timeText;
  final String chipLabel;
  final bool showDot;

  const NotificationItemCard({
    super.key,
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
        color: const Color(0xFFFFFAF8),
        border: Border.all(color: const Color(0xFFFFD0BE)),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F0EC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.orange, size: 30),
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
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFA2A0B0),
                      ),
                    ),
                    if (showDot) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFFFD0BE)),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    chipLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.orange,
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
