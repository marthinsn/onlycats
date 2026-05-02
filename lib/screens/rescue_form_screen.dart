import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/rescue_service.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';

class RescueFormScreen extends StatefulWidget {
  const RescueFormScreen({super.key});

  @override
  State<RescueFormScreen> createState() => _RescueFormScreenState();
}

class _RescueFormScreenState extends State<RescueFormScreen> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final RescueService rescueService = RescueService();
  final CloudinaryService cloudinaryService = CloudinaryService();

  bool isSubmitting = false;
  File? selectedImage;

  final List<String> conditionOptions = [
    'Terlantar',
    'Sakit',
    'Terluka',
    'Butuh Makanan',
  ];

  final Set<String> selectedConditions = {};

  @override
  void dispose() {
    locationController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (pickedFile == null) return;

    setState(() {
      selectedImage = File(pickedFile.path);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EE),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                child: Column(
                  children: [
                    _buildUploadCard(),
                    const SizedBox(height: 18),
                    _buildLocationCard(),
                    const SizedBox(height: 18),
                    _buildConditionCard(),
                    const SizedBox(height: 18),
                    _buildDescriptionCard(),
                    const SizedBox(height: 18),
                    _buildPhoneCard(),
                    const SizedBox(height: 18),
                    _buildNotesCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomButton(),
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
              'Ajukan Rescue',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.orange,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard() {
    return _sectionCard(
      title: 'Foto Kucing',
      child: GestureDetector(
        onTap: isSubmitting ? null : _pickImage,
        child: Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7F3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD2C2), width: 2),
          ),
          child: selectedImage == null
              ? const Center(
                  child: Text(
                    'Upload foto kucing',
                    style: TextStyle(fontSize: 16, color: AppColors.orange),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.file(
                    selectedImage!,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return _sectionCard(
      title: 'Lokasi',
      child: _buildTextField(
        controller: locationController,
        hintText: 'Contoh: Jakarta Selatan',
      ),
    );
  }

  Widget _buildConditionCard() {
    return _sectionCard(
      title: 'Kondisi Kucing',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: conditionOptions.map((condition) {
          final isSelected = selectedConditions.contains(condition);

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedConditions.remove(condition);
                } else {
                  selectedConditions.add(condition);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFE8DE)
                    : const Color(0xFFF9EDE8),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                condition,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? AppColors.orange
                      : const Color(0xFFFF7B42),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return _sectionCard(
      title: 'Deskripsi',
      child: _buildTextField(
        controller: descriptionController,
        hintText: 'Ceritakan kondisi kucing...',
        maxLines: 5,
      ),
    );
  }

  Widget _buildPhoneCard() {
    return _sectionCard(
      title: 'Nomor HP',
      child: _buildTextField(
        controller: phoneController,
        hintText: '08xxxxxxxxxx',
      ),
    );
  }

  Widget _buildNotesCard() {
    return _sectionCard(
      title: 'Catatan Tambahan',
      child: _buildTextField(
        controller: notesController,
        hintText: 'Info tambahan (opsional)',
        maxLines: 5,
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE9E2DE))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: isSubmitting ? null : _submitRescueReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orange,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            isSubmitting ? 'Mengirim...' : 'Kirim Laporan Rescue',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
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
              fontWeight: FontWeight.w700,
              color: Color(0xFF8D8B89),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF8F8B89), fontSize: 16),
        filled: true,
        fillColor: const Color(0xFFF8F1EE),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE4D8D2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.orange),
        ),
      ),
      style: const TextStyle(fontSize: 16, color: Colors.black),
    );
  }

  Future<void> _submitRescueReport() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User belum login')));
      return;
    }

    if (selectedImage == null ||
        locationController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        selectedConditions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mohon lengkapi foto, lokasi, kondisi, deskripsi, dan nomor HP',
          ),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final rescuePhotoUrl = await cloudinaryService.uploadImage(
        selectedImage!,
        folder: 'onlycats/rescue_reports',
      );

      await rescueService.createRescueReport(
        userId: user.uid,
        location: locationController.text.trim(),
        conditions: selectedConditions.toList(),
        description: descriptionController.text.trim(),
        phone: phoneController.text.trim(),
        notes: notesController.text.trim(),
        rescuePhotoUrl: rescuePhotoUrl,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan rescue berhasil dikirim')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim laporan: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }
}
