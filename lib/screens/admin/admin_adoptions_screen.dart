import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'admin_adoption_detail_screen.dart';
import 'admin_bottom_nav.dart';

class AdminAdoptionsScreen extends StatefulWidget {
  const AdminAdoptionsScreen({super.key});

  @override
  State<AdminAdoptionsScreen> createState() => _AdminAdoptionsScreenState();
}

class _AdminAdoptionsScreenState extends State<AdminAdoptionsScreen> {
  String _filterStatus = 'Semua';

  final List<String> _statuses = ['Semua', 'on hold', 'approved', 'rejected'];

  Stream<QuerySnapshot> get _stream {
    Query query = FirebaseFirestore.instance
        .collection('adoptions')
        .orderBy('createdAt', descending: true);

    if (_filterStatus != 'Semua') {
      query = query.where('status', isEqualTo: _filterStatus);
    }

    return query.snapshots();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.green;
      case 'rejected':
        return AppColors.danger;
      default:
        return AppColors.orange;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFFE4F9EC);
      case 'rejected':
        return const Color(0xFFFFEDEC);
      default:
        return const Color(0xFFFFF0E8);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'On Hold';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 14),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _stream,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.orange),
                    );
                  }

                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        'Gagal memuat ajuan adopsi: ${snap.error}',
                        style: const TextStyle(color: AppColors.secondaryText),
                      ),
                    );
                  }

                  final docs = snap.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return _buildEmpty();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return _buildAdoptionCard(adoptionId: doc.id, data: data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Ajuan Adopsi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.only(left: 56),
            child: Text(
              'Kelola semua form adopsi user',
              style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
            ),
          ),
          const SizedBox(height: 16),
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _statuses.map((status) {
          final selected = _filterStatus == status;

          return GestureDetector(
            onTap: () {
              setState(() {
                _filterStatus = status;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF203554) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF203554)
                      : const Color(0xFFE0DDD9),
                ),
              ),
              child: Text(
                status == 'Semua' ? 'Semua' : _statusLabel(status),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.secondaryText,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAdoptionCard({
    required String adoptionId,
    required Map<String, dynamic> data,
  }) {
    final status = data['status'] ?? 'on hold';
    final catName = data['catName'] ?? '-';
    final catBreed = data['catBreed'] ?? '-';
    final fullName = data['fullName'] ?? '-';
    final city = data['city'] ?? '-';
    final catImage = data['catImage'] ?? '';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminAdoptionDetailScreen(
              adoptionId: adoptionId,
              adoptionData: data,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildCatImage(catImage),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    catName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    catBreed,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pengaju: $fullName',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kota: $city',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _statusBg(status),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                _statusLabel(status),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _statusColor(status),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          color: const Color(0xFFF3ECE8),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.pets_rounded,
          color: AppColors.orange,
          size: 34,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        imageUrl,
        width: 78,
        height: 78,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: const Color(0xFFF3ECE8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.broken_image_outlined,
              color: Colors.grey,
              size: 34,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline_rounded,
            size: 72,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            _filterStatus == 'Semua'
                ? 'Belum ada ajuan adopsi'
                : 'Tidak ada ajuan ${_statusLabel(_filterStatus)}',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
