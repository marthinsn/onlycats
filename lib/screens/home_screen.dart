import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../theme/app_colors.dart';
import '../widgets/cat_card.dart';
import '../widgets/category_card.dart';
import '../widgets/filter_chip_item.dart';
import 'rescue_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import 'cat_detail_screen.dart';
import 'adoption_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentBottomNav = 0;

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
            const SizedBox(height: 18),
            _buildAlertBox(),
            const SizedBox(height: 22),
            _buildFilterSection(),
            const SizedBox(height: 22),
            const Text(
              '5 Kucing Ditemukan',
              style: TextStyle(
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
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang 👋',
                style: TextStyle(fontSize: 16, color: AppColors.secondaryText),
              ),
              SizedBox(height: 4),
              Text(
                'OnlyCats',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF203554),
                ),
              ),
              SizedBox(height: 14),
              Text(
                'Halo, Penyelamat Kucing!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                ),
              ),
              SizedBox(height: 6),
              Text(
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
                child: const Text(
                  'A',
                  style: TextStyle(
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
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Color(0xFFAAAAAA)),
          hintText: 'Cari nama, ras, lokasi...',
          hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
          border: InputBorder.none,
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

  Widget _buildAlertBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFFC8C1)),
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFFFFFBFA),
      ),
      child: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: AppColors.danger),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '1 kucing butuh bantuan segera!',
              style: TextStyle(
                color: AppColors.danger,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            'Lihat',
            style: TextStyle(
              color: AppColors.danger,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
}
