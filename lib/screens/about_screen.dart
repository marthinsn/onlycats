import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Tentang Aplikasi',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.orange, AppColors.softOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppHeader(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Tentang Pengembang'),
                  const SizedBox(height: 12),
                  _buildDeveloperInfo(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Mengapa Kami Membuat OnlyCats'),
                  const SizedBox(height: 12),
                  _buildWhyThisAppCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryText,
      ),
    );
  }

  Widget _buildAppHeader() {
    return _buildCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.orange, AppColors.softOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OnlyCats',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
                Text(
                  'Versi 1.0.0',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Penyelamat Kucing',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
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

  Widget _buildDeveloperInfo() {
    return _buildCard(
      child: Row(
        children: [
          const Icon(Icons.volunteer_activism_outlined, color: AppColors.orange, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Aplikasi ini dikembangkan oleh komunitas pencinta kucing yang peduli dengan nasib kucing-kucing terlantar di jalanan.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.secondaryText,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyThisAppCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWhyItem(
            Icons.favorite_rounded,
            'Mengapa OnlyCats?',
            'Masih banyak kucing di sekitar kita yang membutuhkan bantuan medis dan tempat tinggal yang layak. OnlyCats hadir untuk menjembatani antara relawan penyelamat dan calon adopter yang ingin memberikan kasih sayang kepada teman bulu mereka.',
          ),
          const Divider(height: 24, thickness: 1, color: AppColors.border),
          _buildWhyItem(
            Icons.sos_rounded,
            'Rescue Kucing Terlantar',
            'Membantu melaporkan penemuan kucing yang sedang dalam kondisi darurat agar segera mendapatkan pertolongan dari komunitas.',
          ),
          const Divider(height: 24, thickness: 1, color: AppColors.border),
          _buildWhyItem(
            Icons.home_work_rounded,
            'Adopsi Gratis & Aman',
            'Menyediakan platform adopsi kucing tanpa biaya, dengan proses verifikasi yang memastikan kucing berada di tangan yang tepat.',
          ),
          const Divider(height: 24, thickness: 1, color: AppColors.border),
          _buildWhyItem(
            Icons.people_alt_rounded,
            'Komunitas Terpercaya',
            'Membangun ekosistem transparan bagi para relawan untuk memantau status rescue dan proses adopsi secara real-time.',
          ),
        ],
      ),
    );
  }

  Widget _buildWhyItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.orange, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper untuk pengganti AppCard yang tidak ada
  Widget _buildCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
