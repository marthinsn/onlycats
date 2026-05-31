import 'package:flutter/material.dart';
import '../models/cat_model.dart';
import '../theme/app_colors.dart';
import 'adoption_form_screen.dart';
import '../services/favorite_service.dart';

class CatDetailScreen extends StatelessWidget {
  final CatModel cat;

  const CatDetailScreen({super.key, required this.cat});

  Widget _buildCatImage() {
    final image = cat.image.trim();

    if (image.isEmpty) {
      return Container(
        color: const Color(0xFFEFE8E4),
        child: const Center(
          child: Icon(Icons.image_outlined, size: 80, color: Color(0xFFC9C9C9)),
        ),
      );
    }

    if (image.startsWith('http')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFEFE8E4),
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 80,
                color: Color(0xFFC9C9C9),
              ),
            ),
          );
        },
      );
    }

    return Image.asset(image, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    SizedBox(
                      height: 430,
                      width: double.infinity,
                      child: _buildCatImage(),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      top: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _circleButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                          _circleButton(
                            icon: Icons.share_outlined,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 24,
                      bottom: 22,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Tersedia',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _CarouselDot(active: true),
                          _CarouselDot(active: false),
                          _CarouselDot(active: false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -10),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopInfoCard(context),
                          const SizedBox(height: 22),
                          _sectionTitle('INFORMASI KUCING'),
                          const SizedBox(height: 12),
                          _buildInfoGrid(),
                          const SizedBox(height: 22),
                          _sectionTitle('STATUS KESEHATAN'),
                          const SizedBox(height: 12),
                          _buildHealthStatus(),
                          const SizedBox(height: 22),
                          _sectionTitle('TENTANG ${cat.name.toUpperCase()}'),
                          const SizedBox(height: 12),
                          _buildDescriptionCard(),
                          const SizedBox(height: 22),
                          _sectionTitle('KEPRIBADIAN'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: cat.personalities.isNotEmpty
                                ? cat.personalities
                                      .map((item) => _personalityChip(item))
                                      .toList()
                                : [_personalityChip('Belum ada data')],
                          ),
                          const SizedBox(height: 22),
                          _sectionTitle('TEMUI ${cat.name.toUpperCase()} DI'),
                          const SizedBox(height: 12),
                          _buildShelterCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 18,
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFFFD8C7)),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.orange,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdoptionFormScreen(cat: cat),
                          ),
                        );
                      },
                      icon: const Icon(Icons.favorite, color: Colors.white),
                      label: const Text(
                        'Ajukan Adopsi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
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

  Widget _buildTopInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        cat.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryText,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8E7ED),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Icon(
                        cat.gender == 'male' ? Icons.male : Icons.female,
                        size: 20,
                        color: cat.gender == 'male' ? Colors.blue : Colors.pink,
                      ),
                    ),
                  ],
                ),
              ),
              StreamBuilder<bool>(
                stream: FavoriteService().isFavorite(cat.id),
                builder: (context, snapshot) {
                  final isFav = snapshot.data ?? false;

                  return InkWell(
                    borderRadius: BorderRadius.circular(26),
                    onTap: () async {
                      try {
                        await FavoriteService().toggleFavorite(cat, isFav);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFav
                                  ? '${cat.name} dihapus dari favorit'
                                  : '${cat.name} ditambahkan ke favorit',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal favorit: $e')),
                        );
                      }
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFD8C7)),
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: AppColors.orange,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${cat.breed} · ${cat.age}',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.orange,
                size: 20,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  cat.location,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.secondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (cat.vaccinated)
                _tag(
                  'Vaksin',
                  const Color(0xFFEDE6E0),
                  const Color(0xFF127B60),
                ),
              if (cat.sterilized)
                _tag(
                  'Steril',
                  const Color(0xFFF7E7ED),
                  const Color(0xFF1F64B2),
                ),
              _tag('Sehat', const Color(0xFFE6EFDA), const Color(0xFF3D6F12)),
              _tag('Jinak', const Color(0xFFEDE6E0), const Color(0xFFA45A1E)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _infoBox('Ras', cat.breed)),
            const SizedBox(width: 12),
            Expanded(child: _infoBox('Usia', cat.age)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _infoBox(
                'Jenis Kelamin',
                cat.gender == 'male' ? 'Jantan' : 'Betina',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _infoBox('Warna', cat.color)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _infoBox('Berat', cat.weight)),
            const SizedBox(width: 12),
            Expanded(child: _infoBox('Ukuran', cat.size)),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthStatus() {
    return Row(
      children: [
        Expanded(
          child: _healthCard(
            icon: Icons.check,
            title: 'Vaksin',
            value: cat.vaccinated ? 'Lengkap' : 'Belum',
            valueColor: const Color(0xFF127B60),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _healthCard(
            icon: Icons.check,
            title: 'Steril',
            value: cat.sterilized ? 'Sudah' : 'Belum',
            valueColor: const Color(0xFF1F64B2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _healthCard(
            icon: Icons.check,
            title: 'FIV/FeLV',
            value: 'Negatif',
            valueColor: const Color(0xFFA54B16),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8DDD7)),
      ),
      child: Text(
        cat.description,
        style: const TextStyle(
          fontSize: 16,
          height: 1.8,
          color: Color(0xFF5F5D5A),
        ),
      ),
    );
  }

  Widget _buildShelterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8DDD7)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F0EC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.home_outlined,
              color: AppColors.orange,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat.shelterName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  '${cat.shelterLocation} · ${cat.shelterSince}',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.secondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF8F0EB),
              border: Border.all(color: const Color(0xFFE9DCD4)),
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DDD7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFFB8B0AA)),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF363535),
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthCard({
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DDD7)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF3ECE8),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: valueColor, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 15, color: Color(0xFF8A8581)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _personalityChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFFCDBA)),
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFFFFFAF7),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFFA14F1F),
        ),
      ),
    );
  }

  Widget _tag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: Color(0xFFB8B0AA),
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryText, size: 24),
      ),
    );
  }
}

class _CarouselDot extends StatelessWidget {
  final bool active;

  const _CarouselDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: active ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
