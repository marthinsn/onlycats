import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../theme/app_colors.dart';
import '../../services/admin_service.dart';
import '../../widgets/cat_loading.dart';
import 'admin_home_screen.dart';
import 'admin_chat_list_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();

  late Future<AdminStats> _statsFuture;
  late Future<List<RecentRescue>> _recentRescueFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _statsFuture = _adminService.fetchStats();
    _recentRescueFuture = _adminService.fetchRecentRescues();
  }

  void _refresh() {
    setState(() {
      _loadData();
    });
  }

  void _goBackToAdminHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _buildChatFAB(),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.orange,
          onRefresh: () async => _refresh(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                sliver: SliverToBoxAdapter(child: _buildHeader(currentEmail)),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverToBoxAdapter(child: _buildStatsSection()),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverToBoxAdapter(child: _buildRescueStatusSection()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                sliver: SliverToBoxAdapter(child: _buildRecentRescueSection()),
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
          .collection('chat_rooms')
          .where('unreadByAdmin', isEqualTo: true)
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
                  MaterialPageRoute(builder: (_) => const AdminChatListScreen()),
                );
              },
              backgroundColor: const Color(0xFF203554),
              elevation: 4,
              child: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
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

  Widget _buildHeader(String email) {
    return Row(
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: _goBackToAdminHome,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Analitik & Statistik',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Insights',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryText,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: _refresh,
            customBorder: const CircleBorder(),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: AppColors.primaryText,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return FutureBuilder<AdminStats>(
      future: _statsFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CatLoading(size: 40));
        }

        final s = snap.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Ringkasan Inventory'),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.pets_rounded,
                    iconColor: Colors.indigo,
                    iconBg: const Color(0xFFE8EAF6),
                    label: 'Total Kucing',
                    value: '${s.totalCats}',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _StatCard(
                    icon: Icons.sos_rounded,
                    iconColor: AppColors.danger,
                    iconBg: const Color(0xFFFFEBEE),
                    label: 'Laporan Rescue',
                    value: '${s.totalRescueReports}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.favorite_rounded,
                    iconColor: AppColors.orange,
                    iconBg: const Color(0xFFFFF3E0),
                    label: 'Total Adopsi',
                    value: '${s.totalAdoptions}',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _StatCard(
                    icon: Icons.pending_actions_rounded,
                    iconColor: Colors.teal,
                    iconBg: const Color(0xFFE0F2F1),
                    label: 'Adopsi Pending',
                    value: '${s.pendingAdoptions}',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildRescueStatusSection() {
    return FutureBuilder<AdminStats>(
      future: _statsFuture,
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();

        final s = snap.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Status Operasional'),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _RescueStatusRow(
                    label: 'Laporan Menunggu',
                    count: s.pendingRescue,
                    color: AppColors.danger,
                    total: s.totalRescueReports,
                  ),
                  const SizedBox(height: 18),
                  _RescueStatusRow(
                    label: 'Sedang Diproses',
                    count: s.inProgressRescue,
                    color: AppColors.orange,
                    total: s.totalRescueReports,
                  ),
                  const SizedBox(height: 18),
                  _RescueStatusRow(
                    label: 'Telah Selesai',
                    count: s.doneRescue,
                    color: AppColors.green,
                    total: s.totalRescueReports,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentRescueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Aktivitas Terkini'),
        const SizedBox(height: 14),
        FutureBuilder<List<RecentRescue>>(
          future: _recentRescueFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CatLoading(size: 30));
            }

            final list = snap.data ?? [];

            if (list.isEmpty) {
              return _buildEmptyState('Belum ada laporan rescue');
            }

            return Column(
              children: list
                  .map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RecentRescueCard(rescue: r),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: AppColors.primaryText,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: AppColors.iconGrey.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: AppColors.secondaryText, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
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
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RescueStatusRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _RescueStatusRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _RecentRescueCard extends StatelessWidget {
  final RecentRescue rescue;

  const _RecentRescueCard({required this.rescue});

  Color _statusColor(String status) {
    switch (status) {
      case 'Diproses':
        return AppColors.orange;
      case 'Selesai':
        return AppColors.green;
      default:
        return AppColors.danger;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'Diproses':
        return const Color(0xFFFFF3E0);
      case 'Selesai':
        return const Color(0xFFE8F5E9);
      default:
        return const Color(0xFFFFEBEE);
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sos_rounded, color: AppColors.danger, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rescue.location,
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
                  _formatDate(rescue.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusBg(rescue.status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              rescue.status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: _statusColor(rescue.status),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
