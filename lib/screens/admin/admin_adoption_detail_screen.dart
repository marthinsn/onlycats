import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';

class AdminAdoptionDetailScreen extends StatefulWidget {
  final String adoptionId;
  final Map<String, dynamic> adoptionData;

  const AdminAdoptionDetailScreen({
    super.key,
    required this.adoptionId,
    required this.adoptionData,
  });

  @override
  State<AdminAdoptionDetailScreen> createState() =>
      _AdminAdoptionDetailScreenState();
}

class _AdminAdoptionDetailScreenState extends State<AdminAdoptionDetailScreen> {
  late String status;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    status = widget.adoptionData['status'] ?? 'on hold';
  }

  Color _statusColor(String value) {
    switch (value) {
      case 'approved':
        return AppColors.green;
      case 'rejected':
        return AppColors.danger;
      default:
        return AppColors.orange;
    }
  }

  Color _statusBg(String value) {
    switch (value) {
      case 'approved':
        return const Color(0xFFE4F9EC);
      case 'rejected':
        return const Color(0xFFFFEDEC);
      default:
        return const Color(0xFFFFF0E8);
    }
  }

  String _statusLabel(String value) {
    switch (value) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'On Hold';
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    if (status == newStatus) return;

    setState(() {
      isUpdating = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('adoptions')
          .doc(widget.adoptionId)
          .update({
            'status': newStatus,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      final userId = widget.adoptionData['userId']?.toString() ?? '';
      final catId = widget.adoptionData['catId']?.toString() ?? '';
      final catName = widget.adoptionData['catName']?.toString() ?? 'kucing';
      final shelterName = widget.adoptionData['shelterName']?.toString() ?? '-';

      if (userId.isNotEmpty) {
        String message;

        if (newStatus == 'approved') {
          message =
              'Ajuan adopsi kamu untuk $catName disetujui. '
              'Silahkan temui $catName di $shelterName.';
        } else if (newStatus == 'rejected') {
          message = 'Ajuan adopsi kamu untuk $catName belum dapat disetujui.';
        } else {
          message = 'Ajuan adopsi kamu untuk $catName sedang diproses admin.';
        }

        await NotificationService().createNotification(
          userId: userId,
          title: 'Status adopsi diperbarui',
          message: message,
          type: 'adoption_status',
          adoptionId: widget.adoptionId,
          catId: catId,
        );
      }

      if (!mounted) return;

      setState(() {
        status = newStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status berhasil diubah ke ${_statusLabel(newStatus)}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengubah status: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.adoptionData;

    final catName = data['catName'] ?? '-';
    final catImage = data['catImage'] ?? '';
    final catBreed = data['catBreed'] ?? '-';
    final catAge = data['catAge'] ?? '-';
    final shelterName = data['shelterName'] ?? '-';
    final shelterLocation = data['shelterLocation'] ?? '-';

    final fullName = data['fullName'] ?? '-';
    final phone = data['phone'] ?? '-';
    final city = data['city'] ?? '-';
    final job = data['job'] ?? '-';
    final housingType = data['housingType'] ?? '-';
    final petExperience = data['petExperience'] ?? '-';
    final reason = data['reason'] ?? '-';
    final experience = data['experience'] ?? '-';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionCard(
                      title: 'Kucing yang diajukan',
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$catBreed · $catAge',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$shelterName · $shelterLocation',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    _sectionCard(
                      title: 'Status Ajuan',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _statusBadge(status),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _statusButton('on hold')),
                              const SizedBox(width: 10),
                              Expanded(child: _statusButton('approved')),
                              const SizedBox(width: 10),
                              Expanded(child: _statusButton('rejected')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    _sectionCard(
                      title: 'Data Diri Pengaju',
                      child: Column(
                        children: [
                          _infoRow('Nama lengkap', fullName),
                          _infoRow('Nomor HP', phone),
                          _infoRow('Kota domisili', city),
                          _infoRow('Pekerjaan', job),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    _sectionCard(
                      title: 'Tempat Tinggal',
                      child: Column(
                        children: [
                          _infoRow('Tipe tempat tinggal', housingType),
                          _infoRow('Pengalaman pelihara', petExperience),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    _sectionCard(
                      title: 'Alasan Adopsi',
                      child: _paragraph(reason),
                    ),
                    const SizedBox(height: 18),

                    _sectionCard(
                      title: 'Pengalaman Merawat Hewan',
                      child: _paragraph(experience),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF3ECE8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Detail Ajuan Adopsi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusButton(String value) {
    final selected = status == value;

    return ElevatedButton(
      onPressed: isUpdating ? null : () => _updateStatus(value),
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? const Color(0xFF203554) : Colors.white,
        foregroundColor: selected ? Colors.white : _statusColor(value),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: _statusColor(value).withOpacity(0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: isUpdating && selected
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              _statusLabel(value),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
    );
  }

  Widget _statusBadge(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _statusBg(value),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        _statusLabel(value),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: _statusColor(value),
        ),
      ),
    );
  }

  Widget _buildCatImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          color: const Color(0xFFF3ECE8),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.pets_rounded,
          color: AppColors.orange,
          size: 36,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        imageUrl,
        width: 86,
        height: 86,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: const Color(0xFFF3ECE8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.broken_image_outlined,
              color: Colors.grey,
              size: 36,
            ),
          );
        },
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF8D8B89),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paragraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        height: 1.6,
        color: AppColors.primaryText,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
