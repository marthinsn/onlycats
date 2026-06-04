import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../theme/app_colors.dart';

class AdminRescueDetailScreen extends StatelessWidget {
  final String reportId;
  final Map<String, dynamic> reportData;

  const AdminRescueDetailScreen({
    super.key,
    required this.reportId,
    required this.reportData,
  });

  @override
  Widget build(BuildContext context) {
    final photoUrl = reportData['rescuePhotoUrl'] ?? '';
    final location = reportData['location'] ?? '-';
    final description = reportData['description'] ?? '-';
    final phone = reportData['phone'] ?? '-';
    final notes = reportData['notes'] ?? '-';
    final status = reportData['status'] ?? 'Menunggu';
    final userId = reportData['userId'] ?? '-';
    final conditions = List<String>.from(reportData['conditions'] ?? []);
    final double? lat = (reportData['latitude'] as num?)?.toDouble();
    final double? lng = (reportData['longitude'] as num?)?.toDouble();

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
                    _buildImage(photoUrl),
                    const SizedBox(height: 18),

                    _sectionCard(
                      title: 'Status Laporan',
                      child: _statusBadge(status),
                    ),

                    const SizedBox(height: 18),

                    _sectionCard(
                      title: 'Informasi Lokasi',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoText(location),
                          if (lat != null && lng != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: FlutterMap(
                                  options: MapOptions(
                                    initialCenter: LatLng(lat, lng),
                                    initialZoom: 15,
                                    interactionOptions: const InteractionOptions(
                                      flags: InteractiveFlag.none,
                                    ),
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName: 'com.example.onlycats',
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: LatLng(lat, lng),
                                          width: 40,
                                          height: 40,
                                          child: const Icon(
                                            Icons.location_on,
                                            color: AppColors.orange,
                                            size: 35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    _sectionCard(
                      title: 'Kondisi Kucing',
                      child: conditions.isEmpty
                          ? _infoText('-')
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: conditions.map((item) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9EDE8),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.orange,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),

                    const SizedBox(height: 18),

                    _sectionCard(
                      title: 'Deskripsi',
                      child: _infoText(description),
                    ),

                    const SizedBox(height: 18),

                    _sectionCard(
                      title: 'Nomor HP Pelapor',
                      child: _infoText(phone),
                    ),

                    const SizedBox(height: 18),

                    _sectionCard(
                      title: 'Catatan Tambahan',
                      child: _infoText(notes.toString().isEmpty ? '-' : notes),
                    ),

                    const SizedBox(height: 18),

                    _sectionCard(title: 'ID Pelapor', child: _infoText(userId)),

                    const SizedBox(height: 18),

                    _sectionCard(
                      title: 'ID Laporan',
                      child: _infoText(reportId),
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
              'Detail Laporan Rescue',
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

  Widget _buildImage(String photoUrl) {
    if (photoUrl.toString().isEmpty) {
      return Container(
        width: double.infinity,
        height: 240,
        decoration: BoxDecoration(
          color: const Color(0xFFF3ECE8),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Icon(Icons.image_outlined, size: 56, color: Colors.grey),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.network(
        photoUrl,
        width: double.infinity,
        height: 240,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              color: const Color(0xFFF3ECE8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 56,
                color: Colors.grey,
              ),
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
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF8D8B89),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _infoText(String text) {
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

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;

    switch (status) {
      case 'Diproses':
        bg = const Color(0xFFFFF0E8);
        fg = AppColors.orange;
        break;
      case 'Selesai':
        bg = const Color(0xFFE4F9EC);
        fg = AppColors.green;
        break;
      default:
        bg = const Color(0xFFFFEDEC);
        fg = AppColors.danger;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}
