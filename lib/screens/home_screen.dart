import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../widgets/cat_card.dart';
import 'rescue_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import 'cat_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cat_model.dart';
import '../widgets/category_card.dart';
import '../widgets/cat_loading.dart';
import '../services/user_service.dart';
import 'my_adoptions_screen.dart';
import 'dart:io';
import '../data/profile_controller.dart';
import 'chat_admin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentBottomNav = 0;
  String searchQuery = '';
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatAdminScreen()),
          );
        },
        elevation: 4,
        highlightElevation: 8,
        backgroundColor: AppColors.orange,
        child: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              sliver: SliverToBoxAdapter(
                child: _buildTopSection(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              sliver: SliverToBoxAdapter(
                child: _buildSearchBar(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              sliver: SliverToBoxAdapter(
                child: _buildMenuCards(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              sliver: SliverToBoxAdapter(
                child: _buildCatListFromFirestore(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
            return;
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
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
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

  Widget _buildTopSection() {
    return FutureBuilder<DocumentSnapshot>(
      future: currentUser != null
          ? UserService().getUser(currentUser!.uid)
          : null,
      builder: (context, snapshot) {
        String displayName = "OnlyCats";
        String initial = "O";

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          displayName = data['name'] ?? currentUser?.displayName ?? "OnlyCats";
        } else if (currentUser != null) {
          displayName =
              currentUser?.displayName ??
              currentUser?.email?.split('@').first ??
              "OnlyCats";
        }

        if (displayName.isNotEmpty) {
          initial = displayName[0].toUpperCase();
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selamat Datang 👋',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF203554),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Halo, Penyelamat Kucing!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                AnimatedBuilder(
                  animation: profileController,
                  builder: (context, _) {
                    final profile = profileController.profile;
                    final imagePath = profile.profileImagePath;

                    final avatarInitial =
                        profile.fullName.trim().isNotEmpty &&
                            profile.fullName != 'Nama Pengguna'
                        ? profile.fullName.trim()[0].toUpperCase()
                        : initial;

                    return InkWell(
                      borderRadius: BorderRadius.circular(40),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: const BoxDecoration(
                          color: AppColors.softOrange,
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imagePath != null && imagePath.isNotEmpty
                            ? Image.file(
                                File(imagePath),
                                width: 68,
                                height: 68,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      avatarInitial,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  avatarInitial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildNotificationButton(),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationButton() {
    final user = currentUser;

    Stream<int>? unreadStream;
    if (user != null) {
      unreadStream = FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        );
      },
      child: StreamBuilder<int>(
        stream: unreadStream,
        builder: (context, snapshot) {
          final unreadCount = snapshot.data ?? 0;

          return Stack(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.primaryText,
                  size: 28,
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase().trim();
          });
        },
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: Color(0xFFAAAAAA)),
          hintText: 'Cari nama, ras, lokasi...',
          hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
          border: InputBorder.none,
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFFAAAAAA)),
                  onPressed: () {
                    setState(() {
                      searchQuery = '';
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildMenuCards() {
    return Row(
      children: [
        Expanded(
          child: CategoryCard(
            icon: Icons.priority_high_rounded,
            title: 'Laporkan',
            subtitle: 'Kucing Terlantar',
            iconBg: AppColors.orange,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const RescueScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CategoryCard(
            icon: Icons.favorite_border_rounded,
            title: 'Adopsi',
            subtitle: 'Beri Rumah Baru',
            iconBg: AppColors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyAdoptionsScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCatListFromFirestore() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('cats')
          .where('status', isEqualTo: 'tersedia')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 24),
            child: CatLoading(),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Text(
              'Gagal memuat data kucing: ${snapshot.error}',
              style: const TextStyle(color: AppColors.secondaryText),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        final allCats = docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return CatModel.fromMap(doc.id, data);
        }).toList();

        final cats = allCats.where((cat) {
          final query = searchQuery.toLowerCase();

          return cat.name.toLowerCase().contains(query) ||
              cat.breed.toLowerCase().contains(query) ||
              cat.location.toLowerCase().contains(query) ||
              cat.age.toLowerCase().contains(query);
        }).toList();

        if (cats.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Text(
              searchQuery.isEmpty
                  ? 'Belum ada kucing yang tersedia untuk adopsi'
                  : 'Tidak ada kucing yang cocok dengan "$searchQuery"',
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${cats.length} Kucing Ditemukan',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 18),
            ...cats.map(
              (cat) => CatCard(
                cat: cat,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CatDetailScreen(cat: cat),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
