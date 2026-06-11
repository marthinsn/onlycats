import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'rescue_screen.dart';
import 'edit_profile_screen.dart';
import '../data/profile_controller.dart';
import '../services/user_service.dart';
import '../services/favorite_service.dart';
import '../services/auth_service.dart';
import 'change_password_screen.dart';
import 'favorite_cats_screen.dart';
import 'faq_screen.dart';
import 'about_screen.dart';
import 'my_reports_screen.dart';
import '../widgets/cat_loading.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int currentBottomNav = 2;
  final AuthService _authService = AuthService();
  String _joinedDate = '';
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserFromFirestore();
  }

  Future<void> _loadUserFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await UserService().getUser(user.uid);
      if (!snapshot.exists) {
        if (mounted) setState(() => _isInitialLoading = false);
        return;
      }

      final data = snapshot.data() as Map<String, dynamic>;

      // Fetch and format join date
      Timestamp? createdAt = data['createdAt'] as Timestamp?;

      // Fallback to auth metadata if Firestore createdAt is missing
      if (createdAt == null && user.metadata.creationTime != null) {
        createdAt = Timestamp.fromDate(user.metadata.creationTime!);
      }

      if (createdAt != null) {
        final date = createdAt.toDate();
        final months = [
          'Januari',
          'Februari',
          'Maret',
          'April',
          'Mei',
          'Juni',
          'Juli',
          'Agustus',
          'September',
          'Oktober',
          'November',
          'Desember',
        ];
        _joinedDate = 'Bergabung sejak ${months[date.month - 1]} ${date.year}';
      } else {
        _joinedDate = 'Pahlawan Kucing';
      }

      profileController.updateProfile(
        profileController.profile.copyWith(
          fullName: data['name'] ?? profileController.profile.fullName,
          username: data['username'] ?? profileController.profile.username,
          bio: data['bio'] ?? profileController.profile.bio,
          email: data['email'] ?? profileController.profile.email,
          birthDate: data['birthDate'] ?? profileController.profile.birthDate,
          phone: data['phone'] ?? profileController.profile.phone,
          city: data['city'] ?? profileController.profile.city,
          instagram: data['instagram'] ?? profileController.profile.instagram,
          twitter: data['twitter'] ?? profileController.profile.twitter,
          facebook: data['facebook'] ?? profileController.profile.facebook,
          housingType:
              data['housingType'] ?? profileController.profile.housingType,
          petExperience:
              data['petExperience'] ?? profileController.profile.petExperience,
          gender: data['gender'] ?? profileController.profile.gender,
          profileImagePath:
              data['profileImagePath'] ??
              profileController.profile.profileImagePath,
        ),
      );
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Apakah kamu yakin ingin logout dari akun ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmLogout != true) return;

    try {
      await _authService.signOut();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal logout: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Scaffold(body: Center(child: CatLoading()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNavigation(context),
      body: AnimatedBuilder(
        animation: profileController,
        builder: (context, _) {
          final profile = profileController.profile;

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(profile),
                  const SizedBox(height: 20),
                  _buildStatsCard(),
                  const SizedBox(height: 20),
                  _buildHeroCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('AKTIVITAS'),
                  const SizedBox(height: 12),
                  _buildActivitySection(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('PENGATURAN'),
                  const SizedBox(height: 12),
                  _buildSettingsSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: Color(0xFF9C9CAD),
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return _buildSectionCard(
      children: [
        ProfileMenuTile(
          icon: Icons.person_outline_rounded,
          title: 'Edit Profil',
          iconColor: Colors.blueAccent,
          iconBg: const Color(0xFFE3F2FD),
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
        ProfileMenuTile(
          icon: Icons.lock_outline_rounded,
          title: 'Keamanan Akun',
          iconColor: Colors.teal,
          iconBg: const Color(0xFFE0F2F1),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ChangePasswordScreen(),
              ),
            );
          },
        ),
        ProfileMenuTile(
          icon: Icons.help_outline_rounded,
          title: 'Bantuan & FAQ',
          iconColor: Colors.purple,
          iconBg: const Color(0xFFF3E5F5),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FaqScreen()),
            );
          },
        ),
        ProfileMenuTile(
          icon: Icons.info_outline_rounded,
          title: 'Tentang Aplikasi',
          subtitle: 'v1.0.0',
          iconColor: Colors.amber[800]!,
          iconBg: const Color(0xFFFFF8E1),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            );
          },
        ),
        ProfileMenuTile(
          icon: Icons.logout_rounded,
          title: 'Keluar',
          subtitle: 'Logout dari akun ini',
          isLast: true,
          onTap: _logout,
        ),
      ],
    );
  }

  Widget _buildActivitySection() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildSectionCard(
        children: [
          ProfileMenuTile(
            icon: Icons.favorite_border_rounded,
            title: 'Kucing Favorit',
            subtitle: '0 kucing',
            iconColor: Colors.pink,
            iconBg: const Color(0xFFFCE4EC),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoriteCatsScreen()),
              );
            },
          ),
          const ProfileMenuTile(
            icon: Icons.assignment_outlined,
            title: 'Laporan Saya',
            subtitle: '0 laporan',
            iconColor: AppColors.orange,
            iconBg: const Color(0xFFFFF3E0),
            isLast: true,
          ),
        ],
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FavoriteService().getFavorites(),
      builder: (context, favoriteSnapshot) {
        final favoriteCount = favoriteSnapshot.data?.docs.length ?? 0;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('rescue_reports')
              .where('userId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, reportSnapshot) {
            final reportCount = reportSnapshot.data?.docs.length ?? 0;

            return _buildSectionCard(
              children: [
                ProfileMenuTile(
                  icon: Icons.favorite_border_rounded,
                  title: 'Kucing Favorit',
                  subtitle: '$favoriteCount kucing',
                  iconColor: Colors.pink,
                  iconBg: const Color(0xFFFCE4EC),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FavoriteCatsScreen(),
                      ),
                    );
                  },
                ),
                ProfileMenuTile(
                  icon: Icons.assignment_outlined,
                  title: 'Laporan Saya',
                  subtitle: '$reportCount laporan',
                  iconColor: AppColors.orange,
                  iconBg: const Color(0xFFFFF3E0),
                  isLast: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyReportsScreen(),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProfileHeader(profile) {
    final String? imagePath = profile.profileImagePath;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'profile_avatar',
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.softOrange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: imagePath != null && imagePath.isNotEmpty
                  ? Image.file(
                      File(imagePath),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person_outline,
                          size: 40,
                          color: AppColors.orange,
                        );
                      },
                    )
                  : const Icon(
                      Icons.person_outline,
                      size: 40,
                      color: AppColors.orange,
                    ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${profile.username}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profile.bio.isEmpty ? 'Belum ada bio' : profile.bio,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
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

  Widget _buildStatsCard() {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FavoriteService().getFavorites(),
      builder: (context, favoriteSnapshot) {
        final favoriteCount = favoriteSnapshot.data?.docs.length ?? 0;

        return StreamBuilder<QuerySnapshot>(
          stream: user != null 
              ? FirebaseFirestore.instance
                  .collection('rescue_reports')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots()
              : const Stream.empty(),
          builder: (context, reportSnapshot) {
            final reportCount = reportSnapshot.data?.docs.length ?? 0;

            return Container(
              height: 100,
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
              child: Row(
                children: [
                  _buildStatItem('$favoriteCount', 'Favorit', Icons.favorite_rounded, Colors.pinkAccent),
                  Container(width: 1, height: 40, color: const Color(0xFFF0EBE8)),
                  _buildStatItem('$reportCount', 'Laporan', Icons.assignment_rounded, AppColors.orange),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color.withOpacity(0.7)),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryText,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF9B71).withOpacity(0.9),
            const Color(0xFFFF7A3D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pahlawan Kucing',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _joinedDate.isEmpty ? 'Member OnlyCats' : _joinedDate,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
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
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
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
          }
        },
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: AppColors.orange,
        unselectedItemColor: AppColors.iconGrey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.home_outlined, size: 26),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.home_filled, size: 26),
            ),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.warning_amber_rounded, size: 26),
            ),
            label: 'Rescue',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.person_outline, size: 26),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.person, size: 26),
            ),
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
  final Color? iconColor;
  final Color? iconBg;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.isLast = false,
    this.onTap,
    this.iconColor,
    this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLogout = title == 'Keluar';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: isLast 
          ? const BorderRadius.vertical(bottom: Radius.circular(28))
          : title == 'Edit Profil' 
            ? const BorderRadius.vertical(top: Radius.circular(28))
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(color: Color(0xFFF0EBE8), width: 1),
                  ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isLogout 
                      ? const Color(0xFFFFE5E0) 
                      : (iconBg ?? const Color(0xFFFDF6F0)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: isLogout 
                      ? Colors.redAccent 
                      : (iconColor ?? AppColors.orange),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isLogout ? Colors.redAccent : AppColors.primaryText,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9A9CAD),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: const Color(0xFFC0C2CC).withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

