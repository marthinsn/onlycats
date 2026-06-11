import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/cat_model.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';

class AdoptionFormScreen extends StatefulWidget {
  final CatModel cat;

  const AdoptionFormScreen({super.key, required this.cat});

  @override
  State<AdoptionFormScreen> createState() => _AdoptionFormScreenState();
}

class _AdoptionFormScreenState extends State<AdoptionFormScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();

  String housingType = 'Rumah';
  String petExperience = 'Belum pernah';

  bool isSubmitting = false;

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    jobController.dispose();
    reasonController.dispose();
    experienceController.dispose();
    super.dispose();
  }

  Future<void> _submitAdoptionForm() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Kamu harus login terlebih dahulu');
      return;
    }

    if (fullNameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        jobController.text.trim().isEmpty ||
        reasonController.text.trim().isEmpty ||
        experienceController.text.trim().isEmpty) {
      _showMessage('Mohon lengkapi semua data form adopsi');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final adoptionRef = FirebaseFirestore.instance
          .collection('adoptions')
          .doc();

      await adoptionRef.set({
        'id': adoptionRef.id,

        'userId': user.uid,
        'userEmail': user.email ?? '',

        'catId': widget.cat.id,
        'catName': widget.cat.name,
        'catImage': widget.cat.image,
        'catBreed': widget.cat.breed,
        'catAge': widget.cat.age,
        'catLocation': widget.cat.location,

        'shelterName': widget.cat.shelterName,
        'shelterLocation': widget.cat.shelterLocation,

        'fullName': fullNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'city': cityController.text.trim(),
        'job': jobController.text.trim(),
        'housingType': housingType,
        'petExperience': petExperience,
        'reason': reasonController.text.trim(),
        'experience': experienceController.text.trim(),

        'status': 'on hold',
        'adminNote': '',

        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await NotificationService().createNotification(
        userId: user.uid,
        title: 'Form adopsi berhasil dikirim',
        message:
            'Ajuan adopsi kamu untuk ${widget.cat.name} sedang menunggu ditinjau admin.',
        type: 'adoption_submit',
        adoptionId: adoptionRef.id,
        catId: widget.cat.id,
      );

      // NOTIF UNTUK ADMIN
      await NotificationService().createNotification(
        userId: 'admin',
        title: 'Ajuan Adopsi Baru 🐾',
        message: 'Ada ajuan adopsi baru untuk ${widget.cat.name} dari ${fullNameController.text.trim()}.',
        type: 'adoption_submit_admin',
        adoptionId: adoptionRef.id,
        catId: widget.cat.id,
      );

      if (!mounted) return;

      _showMessage('Form adopsi berhasil dikirim');

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Gagal mengirim form adopsi: $e');
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
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
                    _buildCatSummaryCard(),
                    const SizedBox(height: 18),
                    _sectionCard(
                      title: 'Data Diri',
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: fullNameController,
                            hintText: 'Nama lengkap',
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            controller: phoneController,
                            hintText: 'Nomor HP / WhatsApp',
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            controller: cityController,
                            hintText: 'Kota domisili',
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            controller: jobController,
                            hintText: 'Pekerjaan',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _sectionCard(
                      title: 'Informasi Tempat Tinggal',
                      child: Column(
                        children: [
                          _buildDropdownField(
                            value: housingType,
                            items: const [
                              'Rumah',
                              'Kontrakan',
                              'Apartemen',
                              'Kos',
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                housingType = value;
                              });
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildDropdownField(
                            value: petExperience,
                            items: const [
                              'Belum pernah',
                              'Pernah',
                              'Sudah berpengalaman',
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                petExperience = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _sectionCard(
                      title: 'Alasan Adopsi',
                      child: _buildTextField(
                        controller: reasonController,
                        hintText:
                            'Ceritakan alasan ingin mengadopsi kucing ini...',
                        maxLines: 5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _sectionCard(
                      title: 'Pengalaman Merawat Hewan',
                      child: _buildTextField(
                        controller: experienceController,
                        hintText: 'Ceritakan pengalaman merawat hewan...',
                        maxLines: 5,
                      ),
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

  Widget _buildCatSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: widget.cat.image.startsWith('http')
                ? Image.network(
                    widget.cat.image,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _catImagePlaceholder();
                    },
                  )
                : widget.cat.image.isNotEmpty
                ? Image.asset(
                    widget.cat.image,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                  )
                : _catImagePlaceholder(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.cat.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.cat.breed} · ${widget.cat.age}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.cat.shelterLocation.isNotEmpty
                      ? widget.cat.shelterLocation
                      : widget.cat.location,
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
    );
  }

  Widget _catImagePlaceholder() {
    return Container(
      width: 76,
      height: 76,
      color: const Color(0xFFF3ECE8),
      child: const Icon(Icons.pets_rounded, color: AppColors.orange),
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
              'Form Adopsi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
        ],
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
          onPressed: isSubmitting ? null : _submitAdoptionForm,
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
                  'Kirim Form Adopsi',
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

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F1EE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4D8D2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
