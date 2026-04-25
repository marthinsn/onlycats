import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../services/admin_service.dart';
import 'admin_bottom_nav.dart';
import 'admin_dashboard_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final AdminService _adminService = AdminService();
  late Future<AdminStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _adminService.fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.orange,
          onRefresh: () async {
            setState(() {
              _statsFuture = _adminService.fetchStats();
            });
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildQuickStats(),
              const SizedBox(height: 24),
              _buildMenuGrid(context),
              const SizedBox(height: 24),
              _buildRecentActivitySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF203554), Color(0xFF2E4A72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang, Admin 👋',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
                SizedBox(height: 4),
                Text(
                  'OnlyCats Dashboard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return FutureBuilder<AdminStats>(
      future: _statsFuture,
      builder: (context, snap) {
        final s = snap.data;
        final loading = snap.connectionState == ConnectionState.waiting;

        return Row(
          children: [
            _QuickStatTile(
              label: 'Kucing',
              value: loading ? '-' : '${s!.totalCats}',
              icon: Icons.pets_rounded,
              color: AppColors.purple,
              bg: const Color(0xFFEFE8FA),
            ),
            const SizedBox(width: 12),
            _QuickStatTile(
              label: 'Rescue',
              value: loading ? '-' : '${s!.totalRescueReports}',
              icon: Icons.sos_rounded,
              color: AppColors.danger,
              bg: const Color(0xFFFFEDEC),
            ),
            const SizedBox(width: 12),
            _QuickStatTile(
              label: 'Adopsi',
              value: loading ? '-' : '${s!.totalAdoptions}',
              icon: Icons.favorite_rounded,
              color: AppColors.orange,
              bg: const Color(0xFFFFF0E8),
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
        const Text(
          'Menu Admin',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.1,
          children: [
            _MenuCard(
              icon: Icons.dashboard_rounded,
              label: 'Dashboard',
              subtitle: 'Statistik lengkap',
              color: const Color(0xFF203554),
              bg: const Color(0xFFE8EDF4),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
              ),
            ),
            _MenuCard(
              icon: Icons.sos_rounded,
              label: 'Laporan Rescue',
              subtitle: 'Kelola semua laporan',
              color: AppColors.danger,
              bg: const Color(0xFFFFEDEC),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/admin/rescue'),
            ),
            _MenuCard(
              icon: Icons.pets_rounded,
              label: 'Data Kucing',
              subtitle: 'Tambah & edit kucing',
              color: AppColors.purple,
              bg: const Color(0xFFEFE8FA),
              onTap: () {}, // TODO: admin_cats_screen
            ),
            _MenuCard(
              icon: Icons.favorite_rounded,
              label: 'Adopsi',
              subtitle: 'Kelola form adopsi',
              color: AppColors.orange,
              bg: const Color(0xFFFFF0E8),
              onTap: () {}, // TODO: admin_adoptions_screen
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
        const Text(
          'Aktivitas Terbaru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 14),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('rescue_reports')
              .orderBy('createdAt', descending: true)
              .limit(3)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: AppColors.orange),
                ),
              );
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
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmpty(String msg) {
    return Container(
      padding: const EdgeInsets.all(28),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        msg,
        style: const TextStyle(color: AppColors.secondaryText, fontSize: 15),
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
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

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
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
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
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

  const _ActivityTile({required this.location, required this.status});

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
        return const Color(0xFFFFF0E8);
      case 'Selesai':
        return const Color(0xFFE4F9EC);
      default:
        return const Color(0xFFFFEDEC);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.sos_rounded, color: AppColors.danger, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              location,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
