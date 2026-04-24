import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'rescue_screen.dart';
import 'edit_profile_screen.dart';
import '../data/profile_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int currentBottomNav = 2;

  @override
  void initState() {
    super.initState();
    _loadUserFromFirestore();
  }

  Future<void> _loadUserFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final snapshot = await UserService().getUser(user.uid);

    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;

    profileController.updateProfile(
      profileController.profile.copyWith(
        fullName: data['name'] ?? profileController.profile.fullName,
        username: data['username'] ?? profileController.profile.username,
        bio: data['bio'] ?? profileController.profile.bio,
        email: data['email'] ?? profileController.profile.email,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNavigation(context),
      body: AnimatedBuilder(
        animation: profileController,
        builder: (context, _) {
          final profile = profileController.profile;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(profile),
                  const SizedBox(height: 18),
                  _buildStatsCard(),
                  const SizedBox(height: 18),
                  _buildHeroCard(),
                  const SizedBox(height: 18),
                  const Text(
                    'AKTIVITAS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Color(0xFF9C9CAD),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSectionCard(
                    children: const [
                      ProfileMenuTile(
                        icon: Icons.favorite_border,
                        title: 'Kucing Favorit',
                        subtitle: '1 kucing',
                      ),
                      ProfileMenuTile(
                        icon: Icons.assignment_outlined,
                        title: 'Laporan Saya',
                        subtitle: '0 laporan',
                      ),
                      ProfileMenuTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifikasi',
                        subtitle: 'Aktif',
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'PENGATURAN',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Color(0xFF9C9CAD),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSectionCard(
                    children: [
                      ProfileMenuTile(
                        icon: Icons.person_outline,
                        title: 'Edit Profil',
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          );
                          await _loadUserFromFirestore();
                        },
                      ),
                      const ProfileMenuTile(
                        icon: Icons.lock_outline,
                        title: 'Keamanan Akun',
                      ),
                      const ProfileMenuTile(
                        icon: Icons.help_outline,
                        title: 'Bantuan & FAQ',
                      ),
                      const ProfileMenuTile(
                        icon: Icons.info_outline,
                        title: 'Tentang Aplikasi',
                        subtitle: 'v1.0.0',
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

  Widget _buildProfileHeader(profile) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: const Color(0xFFF8EAEA),
              borderRadius: BorderRadius.circular(37),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 38,
              color: AppColors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  profile.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '@${profile.username}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9A9CAD),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  profile.bio,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFF8EAEA),
              borderRadius: BorderRadius.circular(27),
            ),
            child: const Icon(
              Icons.edit_outlined,
              color: AppColors.orange,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _buildStatItem('1', 'Favorit'),
          _dividerVertical(),
          _buildStatItem('0', 'Laporan'),
          _dividerVertical(),
          _buildStatItem('0', 'Diselamatkan'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dividerVertical() {
    return Container(width: 1, height: 92, color: const Color(0xFFE7E2DE));
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EAEA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6D97A), width: 1),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFCFE6FA),
            child: Icon(
              Icons.workspace_premium_outlined,
              color: AppColors.orange,
              size: 30,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pahlawan Kucing',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Bergabung sejak Maret 2026',
                  style: TextStyle(
                    fontSize: 14,
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

  Widget _buildSectionCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(children: children),
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
        currentIndex: currentBottomNav,
        onTap: (index) {
          if (index == currentBottomNav) return;

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
            return;
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
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_rounded),
            label: 'Rescue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isLast;
  final VoidCallback? onTap;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFEAE5E1), width: 1),
              ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFFF8EAEA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppColors.orange, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
        subtitle: subtitle != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9A9CAD),
                  ),
                ),
              )
            : null,
        trailing: const Icon(
          Icons.chevron_right_rounded,
          size: 28,
          color: Color(0xFFC0C2CC),
        ),
        onTap: onTap,
      ),
    );
  }
}
