import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/cloudinary_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';

class AdminPublishCatScreen extends StatefulWidget {
  final String rescueReportId;
  final Map<String, dynamic> rescueData;

  const AdminPublishCatScreen({
    super.key,
    required this.rescueReportId,
    required this.rescueData,
  });

  @override
  State<AdminPublishCatScreen> createState() => _AdminPublishCatScreenState();
}

class _AdminPublishCatScreenState extends State<AdminPublishCatScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final CloudinaryService cloudinaryService = CloudinaryService();

  File? selectedImage;

  String gender = 'male';
  String catSize = 'Sedang';

  bool vaccinated = false;
  bool sterilized = false;
  bool isSubmitting = false;

  final List<String> personalityOptions = [
    'Jinak',
    'Aktif',
    'Manja',
    'Tenang',
    'Ramah',
    'Pemalu',
  ];

  final Set<String> selectedPersonalities = {};

  @override
  void initState() {
    super.initState();

    locationController.text = widget.rescueData['location'] ?? '';
    descriptionController.text = widget.rescueData['description'] ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    breedController.dispose();
    ageController.dispose();
    locationController.dispose();
    colorController.dispose();
    weightController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

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

  Future<void> _publishCat() async {
    if (selectedImage == null ||
        nameController.text.trim().isEmpty ||
        breedController.text.trim().isEmpty ||
        ageController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        colorController.text.trim().isEmpty ||
        weightController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        selectedPersonalities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mohon lengkapi foto, nama, ras, usia, lokasi, warna, berat, deskripsi, dan kepribadian kucing',
          ),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final adoptionPhotoUrl = await cloudinaryService.uploadImage(
        selectedImage!,
        folder: 'onlycats/adoption_cats',
      );

      final catRef = await FirebaseFirestore.instance.collection('cats').add({
        'sourceRescueReportId': widget.rescueReportId,

        'name': nameController.text.trim(),
        'breed': breedController.text.trim(),
        'age': ageController.text.trim(),
        'location': locationController.text.trim(),
        'image': adoptionPhotoUrl,
        'adoptionPhotoUrl': adoptionPhotoUrl,

        'gender': gender,
        'vaccinated': vaccinated,
        'sterilized': sterilized,
        'available': true,
        'favorite': false,

        'color': colorController.text.trim(),
        'weight': weightController.text.trim(),
        'size': catSize,
        'description': descriptionController.text.trim(),

        'shelterName': 'OnlyCats Rescue',
        'shelterLocation': locationController.text.trim(),
        'shelterSince': 'Baru dipublish',

        'personalities': selectedPersonalities.toList(),

        'status': 'tersedia',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('rescue_reports')
          .doc(widget.rescueReportId)
          .update({
            'publishedCatId': catRef.id,
            'status': 'Selesai',
            'completedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      final reportOwnerUserId = widget.rescueData['userId'];

      if (reportOwnerUserId != null &&
          reportOwnerUserId.toString().isNotEmpty) {
        await NotificationService().createNotification(
          userId: reportOwnerUserId.toString(),
          title: 'Kucing berhasil dipublish',
          message:
              'Laporan rescue kamu sudah selesai dan kucingnya sudah tersedia untuk adopsi.',
          type: 'cat_published',
          rescueReportId: widget.rescueReportId,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kucing berhasil dipublish ke adopsi')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal publish kucing: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rescuePhotoUrl = widget.rescueData['rescuePhotoUrl'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                child: Column(
                  children: [
                    _sectionCard(
                      title: 'Foto Rescue Awal',
                      child: _buildRescueImage(rescuePhotoUrl),
                    ),
                    const SizedBox(height: 18),
                    _sectionCard(
                      title: 'Foto Final Kucing',
                      child: _buildUploadFinalImage(),
                    ),
                    const SizedBox(height: 18),
                    _sectionCard(
                      title: 'Informasi Kucing',
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: nameController,
                            hintText: 'Nama kucing',
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            controller: breedController,
                            hintText: 'Ras, contoh: Domestic Shorthair',
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            controller: ageController,
                            hintText: 'Usia, contoh: 6 bulan',
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            controller: locationController,
                            hintText: 'Lokasi',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _sectionCard(
                      title: 'Detail Fisik',
                      child: Column(
                        children: [
                          _buildDropdownField(
                            value: gender,
                            items: const [
                              DropdownMenuItem(
                                value: 'male',
                                child: Text('Jantan'),
                              ),
                              DropdownMenuItem(
                                value: 'female',
                                child: Text('Betina'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                gender = value;
                              });
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildDropdownField(
                            value: catSize,
                            items: const [
                              DropdownMenuItem(
                                value: 'Kecil',
                                child: Text('Kecil'),
                              ),
                              DropdownMenuItem(
                                value: 'Sedang',
                                child: Text('Sedang'),
                              ),
                              DropdownMenuItem(
                                value: 'Besar',
                                child: Text('Besar'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                catSize = value;
                              });
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            controller: colorController,
                            hintText: 'Warna, contoh: Oren putih',
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            controller: weightController,
                            hintText: 'Berat, contoh: 3 kg',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _sectionCard(
                      title: 'Status Kesehatan',
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: vaccinated,
                            activeColor: AppColors.orange,
                            title: const Text(
                              'Sudah vaksin',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            onChanged: (value) {
                              setState(() {
                                vaccinated = value;
                              });
                            },
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: sterilized,
                            activeColor: AppColors.orange,
                            title: const Text(
                              'Sudah steril',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            onChanged: (value) {
                              setState(() {
                                sterilized = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _sectionCard(
                      title: 'Deskripsi',
                      child: _buildTextField(
                        controller: descriptionController,
                        hintText: 'Ceritakan kondisi dan karakter kucing...',
                        maxLines: 5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _sectionCard(
                      title: 'Kepribadian',
                      child: _buildPersonalityChips(),
                    ),
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

  Widget _buildTopBar() {
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
              'Publish Kucing',
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

  Widget _buildRescueImage(String photoUrl) {
    if (photoUrl.toString().isEmpty) {
      return Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Icon(Icons.image_outlined, color: Colors.grey, size: 44),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        photoUrl,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7F3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.grey,
                size: 44,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUploadFinalImage() {
    return GestureDetector(
      onTap: isSubmitting ? null : _pickImage,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFD2C2), width: 2),
        ),
        child: selectedImage == null
            ? const Center(
                child: Text(
                  'Upload foto final kucing',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.orange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(
                  selectedImage!,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }

  Widget _buildPersonalityChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: personalityOptions.map((personality) {
        final isSelected = selectedPersonalities.contains(personality);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedPersonalities.remove(personality);
              } else {
                selectedPersonalities.add(personality);
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
              border: Border.all(
                color: isSelected ? AppColors.orange : Colors.transparent,
              ),
            ),
            child: Text(
              personality,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.orange : const Color(0xFFFF7B42),
              ),
            ),
          ),
        );
      }).toList(),
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
          onPressed: isSubmitting ? null : _publishCat,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orange,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Publish ke Adopsi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
        hintStyle: const TextStyle(color: Color(0xFF8F8B89), fontSize: 15),
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

  Widget _buildDropdownField({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8F1EE),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
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
    );
  }
}
