<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'admin_adoption_detail_screen.dart';
=======
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
>>>>>>> bda4f5887f94ab3aa27392974386fb9cbb9b1a8e
import 'admin_bottom_nav.dart';

class AdminAdoptionsScreen extends StatefulWidget {
  const AdminAdoptionsScreen({super.key});

  @override
  State<AdminAdoptionsScreen> createState() => _AdminAdoptionsScreenState();
}

class _AdminAdoptionsScreenState extends State<AdminAdoptionsScreen> {
  String _filterStatus = 'Semua';
<<<<<<< HEAD

  final List<String> _statuses = ['Semua', 'on hold', 'approved', 'rejected'];

  Stream<QuerySnapshot> get _stream {
    Query query = FirebaseFirestore.instance
        .collection('adoptions')
        .orderBy('createdAt', descending: true);

    if (_filterStatus != 'Semua') {
      query = query.where('status', isEqualTo: _filterStatus);
    }

    return query.snapshots();
=======
  final List<String> _statuses = ['Semua', 'Menunggu', 'Disetujui', 'Ditolak'];

  Future<void> _updateStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance.collection('adoptions').doc(docId).update({
      'status': newStatus,
    });
  }

  void _showStatusDialog(String docId, String currentStatus) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0DDD9),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ubah Status Adopsi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            ...['Menunggu', 'Disetujui', 'Ditolak'].map((status) {
              final isSelected = status == currentStatus;
              return GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  await _updateStatus(docId, status);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF203554) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF203554)
                          : const Color(0xFFEAE5E1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _statusIcon(status),
                        color: isSelected ? Colors.white : _statusColor(status),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : AppColors.primaryText,
                        ),
                      ),
                      if (isSelected) ...[
                        const Spacer(),
                        const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Disetujui':
        return Icons.check_circle_outline_rounded;
      case 'Ditolak':
        return Icons.cancel_outlined;
      default:
        return Icons.access_time_rounded;
    }
>>>>>>> bda4f5887f94ab3aa27392974386fb9cbb9b1a8e
  }

  Color _statusColor(String status) {
    switch (status) {
<<<<<<< HEAD
      case 'approved':
        return AppColors.green;
      case 'rejected':
=======
      case 'Disetujui':
        return AppColors.green;
      case 'Ditolak':
>>>>>>> bda4f5887f94ab3aa27392974386fb9cbb9b1a8e
        return AppColors.danger;
      default:
        return AppColors.orange;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
<<<<<<< HEAD
      case 'approved':
        return const Color(0xFFE4F9EC);
      case 'rejected':
=======
      case 'Disetujui':
        return const Color(0xFFE4F9EC);
      case 'Ditolak':
>>>>>>> bda4f5887f94ab3aa27392974386fb9cbb9b1a8e
        return const Color(0xFFFFEDEC);
      default:
        return const Color(0xFFFFF0E8);
    }
  }

<<<<<<< HEAD
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

=======
>>>>>>> bda4f5887f94ab3aa27392974386fb9cbb9b1a8e
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
<<<<<<< HEAD
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
=======
>>>>>>> bda4f5887f94ab3aa27392974386fb9cbb9b1a8e
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
            _buildHeader(context),
            const SizedBox(height: 14),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _stream,
=======
            Padding(
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
                      const Text(
                        'Kelola Adopsi',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.only(left: 56),
                    child: Text(
                      'Kelola semua form adopsi masuk',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFilterChips(),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('adoptions')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
>>>>>>> bda4f5887f94ab3aa27392974386fb9cbb9b1a8e
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.orange),
                    );
                  }
<<<<<<< HEAD

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
=======
                  if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  }

                  var docs = snap.data?.docs ?? [];

                  // filter di sisi client
                  if (_filterStatus != 'Semua') {
                    docs = docs
                        .where(
                          (d) =>
                              (d.data() as Map<String, dynamic>)['status'] ==
                              _filterStatus,
                        )
                        .toList();
                  }

                  if (docs.isEmpty) return _buildEmpty();

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final data = doc.data() as Map<String, dynamic>;
                      return _buildAdoptionCard(doc.id, data);
>>>>>>> bda4f5887f94ab3aa27392974386fb9cbb9b1a8e
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

<<<<<<< HEAD
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

=======
>>>>>>> bda4f5887f94ab3aa27392974386fb9cbb9b1a8e
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
<<<<<<< HEAD
        children: _statuses.map((status) {
          final selected = _filterStatus == status;

          return GestureDetector(
            onTap: () {
              setState(() {
                _filterStatus = status;
              });
            },
=======
        children: _statuses.map((s) {
          final selected = _filterStatus == s;
          return GestureDetector(
            onTap: () => setState(() => _filterStatus = s),
>>>>>>> bda4f5887f94ab3aa27392974386fb9cbb9b1a8e
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
<<<<<<< HEAD
                status == 'Semua' ? 'Semua' : _statusLabel(status),
=======
                s,
>>>>>>> bda4f5887f94ab3aa27392974386fb9cbb9b1a8e
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

<<<<<<< HEAD
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
=======
  Widget _buildAdoptionCard(String docId, Map<String, dynamic> data) {
    final status = data['status'] ?? 'Menunggu';
    final fullName = data['fullName'] ?? data['nama'] ?? '-';
    final catName = data['catName'] ?? data['namaKucing'] ?? '-';
    final city = data['city'] ?? data['kota'] ?? '-';
    final phone = data['phone'] ?? data['telepon'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kucing: $catName',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showStatusDialog(docId, status),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBg(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _statusColor(status),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.expand_more_rounded,
                        size: 16,
                        color: _statusColor(status),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF0EEEC), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoChip(Icons.location_on_outlined, city),
              const SizedBox(width: 12),
              _infoChip(Icons.phone_outlined, phone),
            ],
          ),
        ],
>>>>>>> bda4f5887f94ab3aa27392974386fb9cbb9b1a8e
      ),
    );
  }

<<<<<<< HEAD
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
=======
  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.secondaryText),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
        ),
      ],
>>>>>>> bda4f5887f94ab3aa27392974386fb9cbb9b1a8e
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
<<<<<<< HEAD
            Icons.favorite_outline_rounded,
=======
            Icons.favorite_border_rounded,
>>>>>>> bda4f5887f94ab3aa27392974386fb9cbb9b1a8e
            size: 72,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            _filterStatus == 'Semua'
<<<<<<< HEAD
                ? 'Belum ada ajuan adopsi'
                : 'Tidak ada ajuan ${_statusLabel(_filterStatus)}',
=======
                ? 'Belum ada form adopsi'
                : 'Tidak ada adopsi "$_filterStatus"',
>>>>>>> bda4f5887f94ab3aa27392974386fb9cbb9b1a8e
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
