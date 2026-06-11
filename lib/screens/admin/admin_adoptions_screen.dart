import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import 'admin_adoption_detail_screen.dart';

class AdminAdoptionsScreen extends StatefulWidget {
  const AdminAdoptionsScreen({super.key});

  @override
  State<AdminAdoptionsScreen> createState() => _AdminAdoptionsScreenState();
}

class _AdminAdoptionsScreenState extends State<AdminAdoptionsScreen> {
  String _filterStatus = 'Semua';
  final List<String> _statuses = ['Semua', 'Menunggu', 'Disetujui', 'Ditolak'];

  Future<void> _updateStatus(
      String docId, String newStatus, String? catId, String oldStatus, Map<String, dynamic> data) async {
    if (newStatus == oldStatus) return;

    final batch = FirebaseFirestore.instance.batch();

    // Update adoption
    final adoptionRef =
        FirebaseFirestore.instance.collection('adoptions').doc(docId);
    batch.update(adoptionRef, {
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update cat if catId exists
    if (catId != null && catId.isNotEmpty) {
      final catRef = FirebaseFirestore.instance.collection('cats').doc(catId);

      if (newStatus == 'approved') {
        batch.update(catRef, {'status': 'diadopsi'});
      } else if (oldStatus == 'approved' && newStatus != 'approved') {
        batch.update(catRef, {'status': 'tersedia'});
      }
    }

    await batch.commit();

    // Send notification
    final userId = data['userId']?.toString() ?? '';
    final catName = data['catName'] ?? data['namaKucing'] ?? 'kucing';
    final shelterName = data['shelterName'] ?? '-';

    if (userId.isNotEmpty) {
      String message;
      if (newStatus == 'approved') {
        message = 'Ajuan adopsi kamu untuk $catName disetujui. Silahkan temui $catName di $shelterName.';
      } else if (newStatus == 'rejected') {
        message = 'Ajuan adopsi kamu untuk $catName belum dapat disetujui.';
      } else {
        message = 'Ajuan adopsi kamu untuk $catName sedang diproses admin.';
      }

      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'title': 'Status adopsi diperbarui',
        'message': message,
        'type': 'adoption_status',
        'adoptionId': docId,
        'catId': catId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void _showStatusDialog(
      String docId, String currentStatus, String? catId, Map<String, dynamic> data) {
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
            ...['Menunggu', 'Disetujui', 'Ditolak'].map((statusName) {
              final mappedCurrentStatus = _mapStatus(currentStatus);
              final isSelected = statusName == mappedCurrentStatus;
              return GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  String dbStatus = statusName;
                  if (statusName == 'Menunggu') dbStatus = 'on hold';
                  if (statusName == 'Disetujui') dbStatus = 'approved';
                  if (statusName == 'Ditolak') dbStatus = 'rejected';

                  await _updateStatus(
                      docId, dbStatus, catId, currentStatus, data);
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
                        _statusIcon(statusName),
                        color: isSelected ? Colors.white : _statusColor(statusName),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        statusName,
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
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Disetujui':
        return AppColors.green;
      case 'Ditolak':
        return AppColors.danger;
      default:
        return AppColors.orange;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'Disetujui':
        return const Color(0xFFE4F9EC);
      case 'Ditolak':
        return const Color(0xFFFFEDEC);
      default:
        return const Color(0xFFFFF0E8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.orange),
                    );
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  }

                  var docs = snap.data?.docs ?? [];

                  // filter di sisi client
                  if (_filterStatus != 'Semua') {
                    docs = docs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      final statusInDb = data['status'] ?? 'on hold';
                      return _mapStatus(statusInDb) == _filterStatus;
                    }).toList();
                  }

                  if (docs.isEmpty) return _buildEmpty();

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final data = doc.data() as Map<String, dynamic>;
                      return _buildAdoptionCard(doc.id, data);
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

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _statuses.map((s) {
          final selected = _filterStatus == s;
          return GestureDetector(
            onTap: () => setState(() => _filterStatus = s),
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
                s,
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

  Widget _buildAdoptionCard(String docId, Map<String, dynamic> data) {
    final rawStatus = data['status'] ?? 'on hold';
    final status = _mapStatus(rawStatus);
    final fullName = data['fullName'] ?? data['nama'] ?? '-';
    final catName = data['catName'] ?? data['namaKucing'] ?? '-';
    final city = data['city'] ?? data['kota'] ?? '-';
    final phone = data['phone'] ?? data['telepon'] ?? '-';
    final catId = data['catId']?.toString();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminAdoptionDetailScreen(
              adoptionId: docId,
              adoptionData: data,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                  onTap: (rawStatus == 'approved' || rawStatus == 'rejected')
                      ? null
                      : () => _showStatusDialog(docId, rawStatus, catId, data),
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
                        if (rawStatus != 'approved' && rawStatus != 'rejected') ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.expand_more_rounded,
                            size: 16,
                            color: _statusColor(status),
                          ),
                        ],
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
        ),
      ),
    );
  }

  String _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'disetujui':
        return 'Disetujui';
      case 'rejected':
      case 'ditolak':
        return 'Ditolak';
      case 'on hold':
      case 'menunggu':
      default:
        return 'Menunggu';
    }
  }

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
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 72,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            _filterStatus == 'Semua'
                ? 'Belum ada form adopsi'
                : 'Tidak ada adopsi "$_filterStatus"',
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
