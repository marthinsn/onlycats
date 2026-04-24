import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/profile_controller.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? selectedImagePath;

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
  final TextEditingController housingTypeController = TextEditingController();
  final TextEditingController petExperienceController = TextEditingController();

  String selectedGender = 'Laki-laki';

  @override
  void initState() {
    super.initState();

    final profile = profileController.profile;

    fullNameController.text = profile.fullName;
    usernameController.text = profile.username;
    bioController.text = profile.bio;
    birthDateController.text = profile.birthDate;
    emailController.text = profile.email;
    phoneController.text = profile.phone;
    cityController.text = profile.city;
    instagramController.text = profile.instagram;
    twitterController.text = profile.twitter;
    facebookController.text = profile.facebook;
    housingTypeController.text = profile.housingType;
    petExperienceController.text = profile.petExperience;

    selectedGender = profile.gender;
    selectedImagePath = profile.profileImagePath;

    fullNameController.addListener(() => setState(() {}));
    usernameController.addListener(() => setState(() {}));
    bioController.addListener(() => setState(() {}));
    birthDateController.addListener(() => setState(() {}));
    emailController.addListener(() => setState(() {}));
    phoneController.addListener(() => setState(() {}));
    cityController.addListener(() => setState(() {}));
    instagramController.addListener(() => setState(() {}));
    twitterController.addListener(() => setState(() {}));
    facebookController.addListener(() => setState(() {}));
    housingTypeController.addListener(() => setState(() {}));
    petExperienceController.addListener(() => setState(() {}));
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImagePath = pickedFile.path;
      });
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
    housingTypeController.dispose();
    petExperienceController.dispose();
    super.dispose();
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
                    const SizedBox(height: 18),
                    _buildAdoptionPreferenceCard(),
                    const SizedBox(height: 18),
                    _buildDangerZoneCard(),
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
              color: const Color(0xFFF5ECE8),
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
              'Edit Profil',
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
                    housingType: housingTypeController.text,
                    petExperience: petExperienceController.text,
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
                    'housingType': housingTypeController.text,
                    'petExperience': petExperienceController.text,
                    'gender': selectedGender,
                    'profileImagePath': selectedImagePath,
                  });

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil berhasil disimpan')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User belum login')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
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
                border: Border.all(color: const Color(0xFFF2C7AF), width: 3),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF2DDD5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: selectedImagePath != null
                      ? Image.file(File(selectedImagePath!), fit: BoxFit.cover)
                      : const Icon(
                          Icons.person,
                          size: 56,
                          color: Color(0xFFFA925A),
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
                    color: AppColors.orange,
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
          fullNameController.text.isEmpty
              ? 'Nama Pengguna'
              : fullNameController.text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          emailController.text.isEmpty
              ? 'pengguna@email.com'
              : emailController.text,
          style: const TextStyle(fontSize: 14, color: Color(0xFFA3A09D)),
        ),
        const SizedBox(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Color(0xFF5B53C8), size: 20),
            SizedBox(width: 6),
            Text(
              'Pahlawan Kucing',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5B53C8),
              ),
            ),
          ],
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
                    _customTextField(controller: birthDateController),
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
          _customTextField(
            controller: cityController,
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF9D948E),
            ),
          ),
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

  Widget _buildAdoptionPreferenceCard() {
    return _sectionCard(
      title: 'PREFERENSI ADOPSI',
      child: Column(
        children: [
          _buildLabel('Tipe Hunian'),
          _customTextField(
            controller: housingTypeController,
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF9D948E),
            ),
          ),
          const SizedBox(height: 18),
          _buildLabel('Pengalaman Pelihara Kucing'),
          _customTextField(
            controller: petExperienceController,
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF9D948E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFB7B2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ZONA BERBAHAYA',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Color(0xFFEF4F45),
            ),
          ),
          const SizedBox(height: 14),
          _dangerTile(
            icon: Icons.star_border_rounded,
            title: 'Nonaktifkan Akun',
            subtitle: 'Akun bisa diaktifkan kembali kapan saja',
          ),
          const Divider(color: Color(0xFFEED6D4), height: 1),
          _dangerTile(
            icon: Icons.delete_outline_rounded,
            title: 'Hapus Akun',
            subtitle: 'Tindakan ini tidak dapat dibatalkan',
          ),
        ],
      ),
    );
  }

  Widget _dangerTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFFFBEAEA),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: const Color(0xFFEF4F45)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFEF4F45),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 13, color: Color(0xFFB0A7A2)),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFFEF4F45),
      ),
      onTap: () {},
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
            color: const Color(0xFFF8EAEA),
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
            if (value != null) {
              setState(() {
                selectedGender = value;
              });
            }
          },
        ),
      ),
    );
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
          borderSide: const BorderSide(color: AppColors.orange),
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
