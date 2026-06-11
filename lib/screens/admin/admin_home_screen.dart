import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../../services/admin_service.dart';
import '../../widgets/cat_loading.dart';
import 'admin_bottom_nav.dart';
import 'admin_dashboard_screen.dart';
import 'admin_cats_screen.dart';
import 'admin_rescue_detail_screen.dart';
import 'admin_adoptions_screen.dart';
import 'admin_chat_list_screen.dart';
import 'admin_users_screen.dart';
import 'admin_notification_screen.dart';
import '../../services/notification_listener_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final AdminService _adminService = AdminService();
  late Future<AdminStats> _statsFuture;
  Timer? _presenceTimer;

  @override
  void initState() {
    super.initState();
    _statsFuture = _adminService.fetchStats();
    _updatePresence();

    // Pastikan listener admin aktif (berguna saat app restart/auto-login)
    NotificationListenerService.startListening('admin');

    // Heartbeat setiap 2 menit
    _presenceTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _updatePresence();
    });
  }

  @override
  void dispose() {
    _presenceTimer?.cancel();
    super.dispose();
  }

  void _updatePresence() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      debugPrint('Updating admin presence for: ${user.email}');
      _adminService.updatePresence(user.uid).catchError((e) {
        debugPrint('Error updating presence: $e');
      });
    }
  }

  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout Admin',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari panel admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
      floatingActionButton: _buildChatFAB(),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.orange,
          onRefresh: () async {
            setState(() {
              _statsFuture = _adminService.fetchStats();
            });
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                sliver: SliverToBoxAdapter(child: _buildHeader()),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverToBoxAdapter(child: _buildQuickStats()),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverToBoxAdapter(child: _buildMenuGrid(context)),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                sliver: SliverToBoxAdapter(child: _buildRecentActivitySection()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatFAB() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: 'admin')
          .where('isRead', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final unreadCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AdminNotificationScreen()),
                );
              },
              backgroundColor: const Color(0xFF203554),
              elevation: 4,
              child:
                  const Icon(Icons.notifications_rounded, color: Colors.white),
            ),
            if (unreadCount > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF203554), Color(0xFF3D5A80)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF203554).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang, Admin 👋',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'OnlyCats Panel',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                tooltip: 'Logout',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return FutureBuilder<AdminStats>(
      future: _statsFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 120,
            child: Center(child: CatLoading(size: 40)),
          );
        }

        final s = snap.data ??
            const AdminStats(
              totalCats: 0,
              totalRescueReports: 0,
              pendingRescue: 0,
              inProgressRescue: 0,
              doneRescue: 0,
              totalAdoptions: 0,
              pendingAdoptions: 0,
            );

        return Row(
          children: [
            _QuickStatTile(
              label: 'Kucing',
              value: '${s.totalCats}',
              icon: Icons.pets_rounded,
              color: Colors.indigo,
              bg: const Color(0xFFE8EAF6),
            ),
            const SizedBox(width: 12),
            _QuickStatTile(
              label: 'Rescue',
              value: '${s.totalRescueReports}',
              icon: Icons.sos_rounded,
              color: AppColors.danger,
              bg: const Color(0xFFFFEBEE),
            ),
            const SizedBox(width: 12),
            _QuickStatTile(
              label: 'Adopsi',
              value: '${s.totalAdoptions}',
              icon: Icons.favorite_rounded,
              color: AppColors.orange,
              bg: const Color(0xFFFFF3E0),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Menu Administrasi'),
        const SizedBox(height: 14),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.15,
          children: [
            _MenuCard(
              icon: Icons.analytics_rounded,
              label: 'Dashboard',
              subtitle: 'Statistik Detail',
              color: Colors.teal,
              bg: const Color(0xFFE0F2F1),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
              ),
            ),
            _MenuCard(
              icon: Icons.sos_rounded,
              label: 'Rescue',
              subtitle: 'Kelola Laporan',
              color: AppColors.danger,
              bg: const Color(0xFFFFEBEE),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/admin/rescue'),
            ),
            _MenuCard(
              icon: Icons.pets_rounded,
              label: 'Inventory',
              subtitle: 'Daftar Kucing',
              color: Colors.indigo,
              bg: const Color(0xFFE8EAF6),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminCatsScreen()),
              ),
            ),
            _MenuCard(
              icon: Icons.favorite_rounded,
              label: 'Adopsi',
              subtitle: 'Formulir Masuk',
              color: AppColors.orange,
              bg: const Color(0xFFFFF3E0),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminAdoptionsScreen()),
              ),
            ),
            _MenuCard(
              icon: Icons.people_alt_rounded,
              label: 'User List',
              subtitle: 'Data Pengguna',
              color: Colors.purple,
              bg: const Color(0xFFF3E5F5),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .where('unreadByAdmin', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                final unreadChatCount =
                    snapshot.hasData ? snapshot.data!.docs.length : 0;

                return _MenuCard(
                  icon: Icons.forum_rounded,
                  label: 'Customer Care',
                  subtitle: 'Chat Aktif',
                  color: Colors.blue,
                  bg: const Color(0xFFE3F2FD),
                  badgeCount: unreadChatCount,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdminChatListScreen()),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Laporan Terbaru'),
        const SizedBox(height: 14),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('rescue_reports')
              .orderBy('createdAt', descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CatLoading(size: 30));
            }
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return _buildEmpty('Belum ada aktivitas terbaru');
            }
            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _ActivityTile(
                  location: data['location'] ?? '-',
                  status: data['status'] ?? 'Menunggu',
                  timestamp: data['createdAt'],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminRescueDetailScreen(
                          reportId: doc.id,
                          reportData: data,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryText,
            letterSpacing: 0.5,
          ),
        ),
        Icon(Icons.chevron_right_rounded,
            color: AppColors.iconGrey.withOpacity(0.5)),
      ],
    );
  }

  Widget _buildEmpty(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded,
              size: 48, color: AppColors.iconGrey.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(
            msg,
            style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _QuickStatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;

  const _QuickStatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryText,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  final int badgeCount;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.bg,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String location;
  final String status;
  final dynamic timestamp;
  final VoidCallback? onTap;

  const _ActivityTile({
    required this.location,
    required this.status,
    this.timestamp,
    this.onTap,
  });

  Color get _statusColor {
    switch (status) {
      case 'Diproses':
        return AppColors.orange;
      case 'Selesai':
        return AppColors.green;
      default:
        return AppColors.danger;
    }
  }

  Color get _statusBg {
    switch (status) {
      case 'Diproses':
        return const Color(0xFFFFF3E0);
      case 'Selesai':
        return const Color(0xFFE8F5E9);
      default:
        return const Color(0xFFFFEBEE);
    }
  }

  String _formatTime() {
    if (timestamp == null) return '';
    DateTime dt;
    if (timestamp is Timestamp) {
      dt = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dt = timestamp;
    } else {
      return '';
    }
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}j';
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.sos_rounded,
                      color: AppColors.danger, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Laporan masuk · ${_formatTime()}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: _statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
