import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../widgets/cat_card.dart';
import '../widgets/filter_chip_item.dart';
import 'rescue_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import 'cat_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cat_model.dart';
import '../widgets/category_card.dart';
import 'adoption_form_screen.dart';
import '../services/user_service.dart';

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
      bottomNavigationBar: Container(
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
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _buildTopSection(),
            const SizedBox(height: 24),
            _buildSearchBar(),
            const SizedBox(height: 22),
            _buildMenuCards(),
            const SizedBox(height: 22),
            _buildFilterSection(),
            const SizedBox(height: 22),
            _buildCatListFromFirestore(),
          ],
        ),
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
          displayName = currentUser?.displayName ?? currentUser?.email?.split('@').first ?? "OnlyCats";
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
                    style: TextStyle(fontSize: 16, color: AppColors.secondaryText),
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
                  const SizedBox(height: 6),
                  const Text(
                    'Ada 5 kucing butuh bantuan mu',
                    style: TextStyle(fontSize: 16, color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(40),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.softOrange,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationScreen()),
                    );
                  },
                  child: Stack(
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
                  ),
                ),
              ],
            ),
          ],
        );
      },
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
                MaterialPageRoute(builder: (_) => const AdoptionFormScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: const [
          FilterChipItem(label: 'Semua', selected: true, icon: Icons.pets),
          SizedBox(width: 12),
          FilterChipItem(label: 'Adopsi', icon: Icons.home_work_outlined),
          SizedBox(width: 12),
          FilterChipItem(label: 'Rescue', icon: Icons.sos),
        ],
      ),
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
            child: Center(
              child: CircularProgressIndicator(color: AppColors.orange),
            ),
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