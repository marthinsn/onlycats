import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNavigation(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 14),
              const Text(
                'Lihat update rescue, adopsi, dan aktivitas akunmu.',
                style: TextStyle(fontSize: 16, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 28),
              _buildSummaryCard(),
              const SizedBox(height: 26),
              const Text(
                'HARI INI',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Color(0xFFB5AAA5),
                ),
              ),
              const SizedBox(height: 14),
              const NotificationItemCard(
                icon: Icons.favorite_border,
                title: 'Permintaan adopsi baru masuk',
                message:
                    'Ada pengguna yang tertarik mengadopsi Oranye. Cek detail permintaan dan lanjutkan proses verifikasi.',
                timeText: '08:45',
                chipLabel: 'Adopsi',
              ),
              const SizedBox(height: 16),
              const NotificationItemCard(
                icon: Icons.access_time,
                title: 'Update status rescue',
                message:
                    'Laporan rescue untuk kucing di Jakarta Selatan sedang ditinjau oleh relawan terdekat.',
                timeText: '07:30',
                chipLabel: 'Rescue',
              ),
              const SizedBox(height: 16),
              const NotificationItemCard(
                icon: Icons.access_time,
                title: 'Pengingat follow up adopsi',
                message:
                    'Jangan lupa cek kembali kandidat adopter yang belum melengkapi informasi rumah dan kontak.',
                timeText: '06:55',
                chipLabel: 'Pengingat',
              ),
              const SizedBox(height: 26),
              const Text(
                'KEMARIN',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Color(0xFFB5AAA5),
                ),
              ),
              const SizedBox(height: 14),
              const NotificationItemCard(
                icon: Icons.check_circle_outline,
                title: 'Rescue berhasil diselesaikan',
                message:
                    'Kucing terlantar yang kamu laporkan telah berhasil diamankan dan sedang dalam perawatan sementara.',
                timeText: 'Kemarin',
                chipLabel: 'Selesai',
                showDot: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFFFD0BE)),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryText,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text(
            'Notifikasi',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
            ),
          ),
        ),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.orange,
            side: const BorderSide(color: Color(0xFFFFD0BE)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          child: const Text(
            'Tandai semua',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF8),
        border: Border.all(color: const Color(0xFFFFD0BE)),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.orange,
            child: Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '3 notifikasi baru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Ada update penting tentang rescue dan adopsi kucing.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
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

  Widget _buildBottomNavigation() {
    return Container(
      height: 84,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE9E4E1))),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        onTap: (_) {},
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
    );
  }
}

class NotificationItemCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String timeText;
  final String chipLabel;
  final bool showDot;

  const NotificationItemCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.timeText,
    required this.chipLabel,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF8),
        border: Border.all(color: const Color(0xFFFFD0BE)),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F0EC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.orange, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFA2A0B0),
                      ),
                    ),
                    if (showDot) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFFFD0BE)),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    chipLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.orange,
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
}
