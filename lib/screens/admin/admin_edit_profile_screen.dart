import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/profile_controller.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_colors.dart';

class AdminEditProfileScreen extends StatefulWidget {
  const AdminEditProfileScreen({super.key});

  @override
  State<AdminEditProfileScreen> createState() => _AdminEditProfileScreenState();
}

class _AdminEditProfileScreenState extends State<AdminEditProfileScreen> {
  String? selectedImagePath;
  bool _isLoading = true;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController twitterController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();

  String selectedGender = 'Laki-laki';

  @override
  void initState() {
    super.initState();
    _loadFromFirestore();
    fullNameController.addListener(() => setState(() {}));
    emailController.addListener(() => setState(() {}));
  }

  Future<void> _loadFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final snap = await UserService().getUser(user.uid);
    if (!snap.exists) {
      setState(() => _isLoading = false);
      return;
    }

    final data = snap.data() as Map<String, dynamic>;

    fullNameController.text = data['name'] ?? '';
    usernameController.text = data['username'] ?? '';
    bioController.text = data['bio'] ?? '';
    birthDateController.text = data['birthDate'] ?? '';
    emailController.text = data['email'] ?? user.email ?? '';
    phoneController.text = data['phone'] ?? '';
    cityController.text = data['city'] ?? '';
    instagramController.text = data['instagram'] ?? '';
    twitterController.text = data['twitter'] ?? '';
    facebookController.text = data['facebook'] ?? '';

    final gender = data['gender'] ?? 'Laki-laki';
    selectedGender = (gender == 'Laki-laki' || gender == 'Perempuan')
        ? gender
        : 'Laki-laki';
    selectedImagePath = data['profileImagePath'];

    setState(() => _isLoading = false);
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => selectedImagePath = pickedFile.path);
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    birthDateController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    instagramController.dispose();
    twitterController.dispose();
    facebookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F1EE),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF203554)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EE),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 18),
                    _buildPersonalInfoCard(),
                    const SizedBox(height: 18),
                    _buildContactCard(),
                    const SizedBox(height: 18),
                    _buildSocialMediaCard(),
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
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEAE3DF))),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDF4),
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primaryText,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Edit Profil Admin',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                final auth = AuthService();
                final userService = UserService();
                final user = auth.currentUser;

                if (user != null) {
                  final updatedProfile = profileController.profile.copyWith(
                    fullName: fullNameController.text,
                    username: usernameController.text,
                    bio: bioController.text,
                    email: emailController.text,
                    birthDate: birthDateController.text,
                    phone: phoneController.text,
                    city: cityController.text,
                    instagram: instagramController.text,
                    twitter: twitterController.text,
                    facebook: facebookController.text,
                    gender: selectedGender,
                    profileImagePath: selectedImagePath,
                  );

                  profileController.updateProfile(updatedProfile);

                  await userService.saveUserData(user.uid, {
                    'name': fullNameController.text,
                    'username': usernameController.text,
                    'bio': bioController.text,
                    'email': emailController.text,
                    'birthDate': birthDateController.text,
                    'phone': phoneController.text,
                    'city': cityController.text,
                    'instagram': instagramController.text,
                    'twitter': twitterController.text,
                    'facebook': facebookController.text,
                    'gender': selectedGender,
                    'profileImagePath': selectedImagePath,
                  });

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil berhasil disimpan')),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF203554),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 26),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Simpan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 136,
              height: 136,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2E4A72), width: 3),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE8EDF4),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: selectedImagePath != null
                      ? Image.file(File(selectedImagePath!), fit: BoxFit.cover)
                      : const Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 56,
                          color: Color(0xFF203554),
                        ),
                ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: 10,
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF203554),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          fullNameController.text.isEmpty ? 'Admin' : fullNameController.text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          emailController.text.isEmpty ? '-' : emailController.text,
          style: const TextStyle(fontSize: 14, color: Color(0xFFA3A09D)),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EDF4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '🛡️ Administrator',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF203554),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoCard() {
    return _sectionCard(
      title: 'INFORMASI PRIBADI',
      child: Column(
        children: [
          _buildLabel('Nama Lengkap'),
          _customTextField(
            controller: fullNameController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          _buildLabel('Username'),
          _customTextField(
            controller: usernameController,
            suffixIcon: const Icon(
              Icons.alternate_email_rounded,
              color: Color(0xFFB2AAA4),
            ),
          ),
          const SizedBox(height: 18),
          _buildLabel('Bio'),
          _customTextField(controller: bioController, maxLines: 4),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildLabel('Jenis Kelamin'), _genderDropdown()],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Tanggal Lahir'),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: birthDateController.text.isNotEmpty
                              ? _parseDate(birthDateController.text)
                              : DateTime(1990, 1, 1),
                          firstDate: DateTime(1940),
                          lastDate: DateTime.now(),
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF203554),
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setState(() {
                            birthDateController.text =
                                '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: _customTextField(
                          controller: birthDateController,
                          suffixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            color: Color(0xFF9D948E),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return _sectionCard(
      title: 'KONTAK',
      child: Column(
        children: [
          _buildLabel('Email'),
          _customTextField(
            controller: emailController,
            suffixIcon: const Icon(Icons.email_outlined, color: Colors.green),
          ),
          const SizedBox(height: 18),
          _buildLabel('Nomor HP / WhatsApp'),
          _customTextField(controller: phoneController),
          const SizedBox(height: 18),
          _buildLabel('Kota / Lokasi'),
          _customTextField(controller: cityController),
        ],
      ),
    );
  }

  Widget _buildSocialMediaCard() {
    return _sectionCard(
      title: 'MEDIA SOSIAL',
      child: Column(
        children: [
          _socialRow(
            icon: Icons.camera_alt_outlined,
            iconColor: const Color(0xFFC47A11),
            label: 'Instagram',
            controller: instagramController,
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFE8DFDB), height: 1),
          const SizedBox(height: 14),
          _socialRow(
            icon: Icons.flutter_dash,
            iconColor: Colors.blue,
            label: 'Twitter / X',
            controller: twitterController,
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFE8DFDB), height: 1),
          const SizedBox(height: 14),
          _socialRow(
            icon: Icons.facebook,
            iconColor: const Color(0xFF4267B2),
            label: 'Facebook',
            controller: facebookController,
          ),
        ],
      ),
    );
  }

  Widget _socialRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required TextEditingController controller,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EDF4),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 14),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5D5A57),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _customTextField(
            controller: controller,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _genderDropdown() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EFEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2D2CB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGender,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF9D948E),
          ),
          style: const TextStyle(fontSize: 15, color: AppColors.primaryText),
          items: const [
            DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
            DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
          ],
          onChanged: (value) {
            if (value != null) setState(() => selectedGender = value);
          },
        ),
      ),
    );
  }

  DateTime _parseDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}
    return DateTime(1990, 1, 1);
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF67615B),
          ),
        ),
      ),
    );
  }

  Widget _customTextField({
    required TextEditingController controller,
    int maxLines = 1,
    Widget? suffixIcon,
    EdgeInsetsGeometry? contentPadding,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF7EFEB),
        suffixIcon: suffixIcon,
        contentPadding:
            contentPadding ??
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2D2CB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF203554)),
        ),
      ),
      style: const TextStyle(fontSize: 15, color: AppColors.primaryText),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEAE2DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Color(0xFFBBB2AB),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
