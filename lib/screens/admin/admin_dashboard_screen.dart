import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../theme/app_colors.dart';
import '../../services/admin_service.dart';
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
      floatingActionButton: StreamBuilder<QuerySnapshot>(
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
                    MaterialPageRoute(
                        builder: (_) => const AdminChatListScreen()),
                  );
                },
                backgroundColor: const Color(0xFF203554),
                child: const Icon(Icons.chat_rounded, color: Colors.white),
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
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.orange,
          onRefresh: () async => _refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              _buildHeader(currentEmail),
              const SizedBox(height: 24),
              _buildStatsSection(),
              const SizedBox(height: 24),
              _buildRescueStatusSection(),
              const SizedBox(height: 24),
              _buildRecentRescueSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader(String email) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _goBackToAdminHome,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
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
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Panel Admin 🛡️',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'OnlyCats',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF203554),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _refresh,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: AppColors.primaryText,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Statistik Utama ──────────────────────────────────────────────────────
  Widget _buildStatsSection() {
    return FutureBuilder<AdminStats>(
      future: _statsFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _buildStatsShimmer();
        }

        if (snap.hasError || !snap.hasData || snap.data == null) {
          return _buildErrorBox('Gagal memuat statistik', _refresh);
        }

        final s = snap.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.pets_rounded,
                    iconColor: AppColors.purple,
                    iconBg: const Color(0xFFEFE8FA),
                    label: 'Total Kucing',
                    value: '${s.totalCats}',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _StatCard(
                    icon: Icons.sos_rounded,
                    iconColor: AppColors.danger,
                    iconBg: const Color(0xFFFFEDEC),
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
                    iconBg: const Color(0xFFFFF0E8),
                    label: 'Total Adopsi',
                    value: '${s.totalAdoptions}',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _StatCard(
                    icon: Icons.pending_actions_rounded,
                    iconColor: const Color(0xFF2DBE60),
                    iconBg: const Color(0xFFE4F9EC),
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

  // ─── Status Rescue ────────────────────────────────────────────────────────
  Widget _buildRescueStatusSection() {
    return FutureBuilder<AdminStats>(
      future: _statsFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snap.hasError || !snap.hasData || snap.data == null) {
          return const SizedBox.shrink();
        }

        final s = snap.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Rescue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _RescueStatusRow(
                    label: 'Menunggu',
                    count: s.pendingRescue,
                    color: AppColors.danger,
                    total: s.totalRescueReports,
                  ),
                  const SizedBox(height: 14),
                  _RescueStatusRow(
                    label: 'Diproses',
                    count: s.inProgressRescue,
                    color: AppColors.orange,
                    total: s.totalRescueReports,
                  ),
                  const SizedBox(height: 14),
                  _RescueStatusRow(
                    label: 'Selesai',
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

  // ─── Laporan Rescue Terbaru ───────────────────────────────────────────────
  Widget _buildRecentRescueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Laporan Rescue Terbaru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 14),
        FutureBuilder<List<RecentRescue>>(
          future: _recentRescueFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.orange),
                ),
              );
            }

            if (snap.hasError) {
              return _buildErrorBox('Gagal memuat laporan terbaru', _refresh);
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

  // ─── Shimmer placeholder ──────────────────────────────────────────────────
  Widget _buildStatsShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _shimmerBox(120)),
            const SizedBox(width: 14),
            Expanded(child: _shimmerBox(120)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _shimmerBox(120)),
            const SizedBox(width: 14),
            Expanded(child: _shimmerBox(120)),
          ],
        ),
      ],
    );
  }

  Widget _shimmerBox(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEBE9),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildErrorBox(String message, VoidCallback onRetry) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFC8C1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRetry,
            child: const Text(
              'Coba lagi',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(28),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: AppColors.iconGrey),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Subwidget: StatCard ──────────────────────────────────────────────────────
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Subwidget: RescueStatusRow ───────────────────────────────────────────────
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
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
            Text(
              '$count laporan',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: const Color(0xFFF0EEEC),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ─── Subwidget: RecentRescueCard ──────────────────────────────────────────────
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
        return const Color(0xFFFFF0E8);
      case 'Selesai':
        return const Color(0xFFE4F9EC);
      default:
        return const Color(0xFFFFEDEC);
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    }

    if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    }

    return '${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDEC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.sos_rounded,
              color: AppColors.danger,
              size: 22,
            ),
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
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(rescue.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
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
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              rescue.status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _statusColor(rescue.status),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
