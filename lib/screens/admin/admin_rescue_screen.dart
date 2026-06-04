import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../theme/app_colors.dart';
import '../../services/notification_service.dart';
import 'admin_bottom_nav.dart';
import 'admin_publish_cat_screen.dart';

class AdminRescueScreen extends StatefulWidget {
  const AdminRescueScreen({super.key});

  @override
  State<AdminRescueScreen> createState() => _AdminRescueScreenState();
}

class _AdminRescueScreenState extends State<AdminRescueScreen> {
  String _filterStatus = 'Semua';
  final List<String> _statuses = ['Semua', 'Menunggu', 'Diproses', 'Selesai'];

  Stream<QuerySnapshot> get _stream {
    return FirebaseFirestore.instance
        .collection('rescue_reports')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _updateStatus({
    required String docId,
    required String newStatus,
    required Map<String, dynamic> reportData,
  }) async {
    final oldStatus = reportData['status'] ?? 'Menunggu';

    if (oldStatus == newStatus) {
      return;
    }

    final reportOwnerUserId = reportData['userId'];

    final updateData = <String, dynamic>{
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (newStatus == 'Selesai') {
      updateData['completedAt'] = FieldValue.serverTimestamp();
    }

    await FirebaseFirestore.instance
        .collection('rescue_reports')
        .doc(docId)
        .update(updateData);

    if (reportOwnerUserId != null && reportOwnerUserId.toString().isNotEmpty) {
      await NotificationService().createNotification(
        userId: reportOwnerUserId.toString(),
        title: 'Status laporan rescue diperbarui',
        message: 'Laporan rescue kamu sekarang berstatus $newStatus.',
        type: newStatus == 'Selesai' ? 'rescue_done' : 'rescue_status',
        rescueReportId: docId,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status laporan berhasil diubah ke $newStatus.')),
    );
  }

  void _showStatusDialog(
    String docId,
    String currentStatus,
    Map<String, dynamic> reportData,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
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
                'Ubah Status Laporan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 16),
              ...['Menunggu', 'Diproses', 'Selesai'].map((status) {
                final isSelected = status == currentStatus;

                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);

                    try {
                      await _updateStatus(
                        docId: docId,
                        newStatus: status,
                        reportData: reportData,
                      );
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal mengubah status: $e')),
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF203554)
                          : Colors.white,
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
                          color: isSelected
                              ? Colors.white
                              : _statusColor(status),
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
        );
      },
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Diproses':
        return Icons.autorenew_rounded;
      case 'Selesai':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Diproses':
        return AppColors.orange;
      case 'Selesai':
        return AppColors.green;
      default:
        return AppColors.danger;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'Diproses':
        return const Color(0xFFFFF0E8);
      case 'Selesai':
        return const Color(0xFFE4F9EC);
      default:
        return const Color(0xFFFFEDEC);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Laporan Rescue',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Kelola semua laporan masuk',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.secondaryText,
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
                stream: _stream,
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
                  if (_filterStatus != 'Semua') {
                    docs = docs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      return data['status'] == _filterStatus;
                    }).toList();
                  }

                  if (docs.isEmpty) {
                    return _buildEmpty();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final data = doc.data() as Map<String, dynamic>;

                      return _buildReportCard(doc.id, data);
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

  Widget _buildReportCard(String docId, Map<String, dynamic> data) {
    final status = data['status'] ?? 'Menunggu';
    final location = data['location'] ?? '-';
    final description = data['description'] ?? '';
    final phone = data['phone'] ?? '-';
    final notes = data['notes'] ?? '';
    final photoUrl = data['rescuePhotoUrl'] ?? '';
    final conditions = List<String>.from(data['conditions'] ?? []);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRescueImage(photoUrl),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showStatusDialog(docId, status, data),
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

                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 8),
                Text(
                  'HP: $phone',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),

                if (notes.toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Catatan: $notes',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                if (conditions.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: conditions.map((c) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9EDE8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          c,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                if (status == 'Selesai' && data['publishedCatId'] == null) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminPublishCatScreen(
                              rescueReportId: docId,
                              rescueData: data,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.pets_rounded, color: Colors.white),
                      label: const Text(
                        'Publish ke Adopsi',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRescueImage(String photoUrl) {
    if (photoUrl.isEmpty) {
      return Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFFF3ECE8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.image_outlined, color: Colors.grey, size: 34),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        photoUrl,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFF3ECE8),
              borderRadius: BorderRadius.circular(16),
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
          Icon(Icons.content_paste_outlined, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _filterStatus == 'Semua'
                ? 'Belum ada laporan rescue'
                : 'Tidak ada laporan "$_filterStatus"',
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
