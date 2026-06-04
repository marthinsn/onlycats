import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cat_model.dart';
import '../services/favorite_service.dart';
import '../theme/app_colors.dart';
import '../widgets/cat_card.dart';
import 'cat_detail_screen.dart';

class FavoriteCatsScreen extends StatelessWidget {
  const FavoriteCatsScreen({super.key});

  CatModel _catFromFavoriteDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CatModel(
      id: data['catId'] ?? doc.id,
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      age: data['age'] ?? '',
      location: data['location'] ?? '',
      image: data['image'] ?? '',
      gender: data['gender'] ?? 'male',
      vaccinated: data['vaccinated'] ?? false,
      sterilized: data['sterilized'] ?? false,
      available: data['available'] ?? true,
      favorite: true,
      color: data['color'] ?? '',
      weight: data['weight'] ?? '',
      size: data['size'] ?? '',
      description: data['description'] ?? '',
      shelterName: data['shelterName'] ?? 'OnlyCats Rescue',
      shelterLocation: data['shelterLocation'] ?? data['location'] ?? '',
      shelterSince: data['shelterSince'] ?? '',
      personalities: List<String>.from(data['personalities'] ?? []),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.primaryText,
        title: const Text(
          'Kucing Favorit',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FavoriteService().getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.orange),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat favorit: ${snapshot.error}'),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada kucing favorit',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final cats = docs.map(_catFromFavoriteDoc).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text(
                '${cats.length} Kucing Favorit',
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
      ),
    );
  }
}
