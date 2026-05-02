import 'package:flutter/material.dart';
import '../models/cat_model.dart';
import '../theme/app_colors.dart';

class CatCard extends StatelessWidget {
  final CatModel cat;
  final VoidCallback? onTap;

  const CatCard({super.key, required this.cat, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFE8E4),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    image: _catImageProvider() != null
                        ? DecorationImage(
                            image: _catImageProvider()!,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: cat.image.isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 60,
                            color: Color(0xFFC7C7C7),
                          ),
                        )
                      : null,
                ),
                Positioned(
                  top: 18,
                  left: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
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
                Positioned(
                  top: 18,
                  right: 18,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Icon(
                      cat.favorite ? Icons.favorite : Icons.favorite_border,
                      color: AppColors.orange,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        cat.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7E7ED),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          cat.gender == 'male' ? Icons.male : Icons.female,
                          size: 17,
                          color: cat.gender == 'male'
                              ? Colors.blue
                              : Colors.pink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${cat.breed} · ${cat.age}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        cat.location,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (cat.vaccinated) _tag('Vaksin'),
                      if (cat.sterilized) _tag('Steril'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _catImageProvider() {
    final image = cat.image.trim();

    if (image.isEmpty) return null;

    if (image.startsWith('http')) {
      return NetworkImage(image);
    }

    return AssetImage(image);
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9EAEA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.green,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
