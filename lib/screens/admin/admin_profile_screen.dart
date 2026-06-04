import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../theme/app_colors.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';
import '../../data/profile_controller.dart';
import 'admin_bottom_nav.dart';
import 'admin_dashboard_screen.dart';
import 'admin_edit_profile_screen.dart';
import 'admin_users_screen.dart';
import 'admin_notification_screen.dart';
import 'admin_change_password_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  String _getAdminNameFromEmail(String email) {
    if (email.isEmpty) return 'Admin';

    final namePart = email.split('@').first.trim();

    if (namePart.isEmpty) return 'Admin';

    return namePart[0].toUpperCase() + namePart.substring(1);
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap = await UserService().getUser(user.uid);
    if (!snap.exists) return;
    final data = snap.data() as Map<String, dynamic>;
    profileController.updateProfile(
      profileController.profile.copyWith(
        fullName: data['name'] ?? '',
        username: data['username'] ?? '',
        email: data['email'] ?? user.email ?? '',
        bio: data['bio'] ?? '',
        birthDate: data['birthDate'] ?? '',
        phone: data['phone'] ?? '',
        city: data['city'] ?? '',
        instagram: data['instagram'] ?? '',
        twitter: data['twitter'] ?? '',
        facebook: data['facebook'] ?? '',
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar dari akun admin?',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        content: const Text(
          'Kamu akan kembali ke halaman login.',
          style: TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Keluar',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authEmail =
        FirebaseAuth.instance.currentUser?.email ?? 'admin@onlycats.com';
    final authName = _getAdminNameFromEmail(authEmail);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
      body: AnimatedBuilder(
        animation: profileController,
        builder: (context, _) {
          final profile = profileController.profile;

          final displayEmail = profile.email.trim().isNotEmpty
              ? profile.email
              : authEmail;

          final displayName =
              profile.fullName.trim().isNotEmpty &&
                  profile.fullName != 'Nama Pengguna'
              ? profile.fullName
              : authName;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAdminHeader(name: displayName, email: displayEmail),
                  const SizedBox(height: 20),
                  _buildDashboardBanner(context),
                  const SizedBox(height: 24),
                  const Text(
                    'MANAJEMEN',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Color(0xFF9C9CAD),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSectionCard(
                    children: [
                      _AdminMenuTile(
                        icon: Icons.manage_accounts_rounded,
                        label: 'Manajemen Akun',
                        subtitle: 'Kelola data pengguna',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminUsersScreen(),
                          ),
                        ),
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'PENGATURAN ADMIN',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Color(0xFF9C9CAD),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSectionCard(
                    children: [
                      _AdminMenuTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Edit Profil',
                        subtitle: 'Ubah nama, username, bio',
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminEditProfileScreen(),
                            ),
                          );
                          await _loadUser();
                        },
                      ),
                      _AdminMenuTile(
                        icon: Icons.lock_outline_rounded,
                        label: 'Ganti Password',
                        subtitle: 'Ubah kata sandi akun',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminChangePasswordScreen(),
                          ),
                        ),
                      ),
                      _AdminMenuTile(
                        icon: Icons.notifications_none_rounded,
                        label: 'Notifikasi',
                        subtitle: 'Pengaturan notifikasi',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminNotificationScreen(),
                          ),
                        ),
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'AKUN',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Color(0xFF9C9CAD),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSectionCard(
                    children: [
                      const _AdminMenuTile(
                        icon: Icons.info_outline,
                        label: 'Tentang Aplikasi',
                        subtitle: 'v1.0.0',
                      ),
                      _AdminMenuTile(
                        icon: Icons.logout_rounded,
                        label: 'Keluar',
                        iconColor: AppColors.danger,
                        labelColor: AppColors.danger,
                        onTap: _logout,
                        isLast: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminHeader({required String name, required String email}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF203554), Color(0xFF2E4A72)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(34),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EDF4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🛡️ Administrator',
                    style: TextStyle(
                      fontSize: 12,
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

  Widget _buildDashboardBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF203554), Color(0xFF2E4A72)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF203554).withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.dashboard_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buka Dashboard',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Statistik kucing, rescue & adopsi',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white54,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _AdminMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? iconColor;
  final Color? labelColor;
  final bool isLast;
  final VoidCallback? onTap;

  const _AdminMenuTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.iconColor,
    this.labelColor,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iColor = iconColor ?? const Color(0xFF203554);
    final iBg = iconColor != null
        ? iconColor!.withValues(alpha: 0.1)
        : const Color(0xFFE8EDF4);

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFEAE5E1), width: 1),
              ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iColor, size: 24),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: labelColor ?? AppColors.primaryText,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              )
            : null,
        trailing: const Icon(
          Icons.chevron_right_rounded,
          size: 26,
          color: Color(0xFFC0C2CC),
        ),
        onTap: onTap,
      ),
    );
  }
}
