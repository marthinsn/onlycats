import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import 'forgot_password_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isOldPasswordVerified = false;
  bool isLoading = false;
  bool obscureOldPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  int failedAttempts = 0;
  static const int maxAttempts = 5;

  @override
  void _goToForgotPassword() {
    final user = FirebaseAuth.instance.currentUser;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ForgotPasswordScreen(initialEmail: user?.email),
      ),
    );
  }

  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyOldPassword() async {
    final oldPassword = oldPasswordController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (oldPassword.isEmpty) {
      _showMessage('Password awal wajib diisi');
      return;
    }

    if (user == null || user.email == null) {
      _showMessage('User belum login');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);

      if (!mounted) return;

      setState(() {
        isOldPasswordVerified = true;
        isLoading = false;
      });

      _showMessage('Password awal benar. Silakan masukkan password baru.');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      failedAttempts++;

      setState(() {
        isLoading = false;
      });

      if (failedAttempts >= maxAttempts) {
        _showMessage('Percobaan sudah 5 kali. Silakan reset password.');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
        );
        return;
      }

      String message =
          'Password awal salah. Sisa percobaan: ${maxAttempts - failedAttempts}';

      if (e.code == 'too-many-requests') {
        message = 'Terlalu banyak percobaan. Coba lagi nanti.';
      } else if (e.code == 'user-disabled') {
        message = 'Akun ini sedang dinonaktifkan.';
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage('Terjadi kesalahan: $e');
    }
  }

  Future<void> _changePassword() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Password baru dan konfirmasi wajib diisi');
      return;
    }

    if (newPassword.length < 6) {
      _showMessage('Password baru minimal 6 karakter');
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('Konfirmasi password tidak sama');
      return;
    }

    if (user == null) {
      _showMessage('User belum login');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await user.updatePassword(newPassword);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage('Password berhasil diganti');

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      String message = 'Gagal mengganti password';

      if (e.code == 'requires-recent-login') {
        message = 'Sesi login sudah terlalu lama. Silakan verifikasi ulang.';
        setState(() {
          isOldPasswordVerified = false;
          oldPasswordController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();
        });
      } else if (e.code == 'weak-password') {
        message = 'Password terlalu lemah';
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage('Terjadi kesalahan: $e');
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionCard(
                      title: isOldPasswordVerified
                          ? 'Password Baru'
                          : 'Verifikasi Password',
                      child: Column(
                        children: [
                          if (!isOldPasswordVerified) ...[
                            _passwordField(
                              controller: oldPasswordController,
                              hintText: 'Masukkan password awal',
                              obscureText: obscureOldPassword,
                              onToggle: () {
                                setState(() {
                                  obscureOldPassword = !obscureOldPassword;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Percobaan gagal: $failedAttempts/$maxAttempts',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _goToForgotPassword,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Lupa Password?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            _passwordField(
                              controller: newPasswordController,
                              hintText: 'Masukkan password baru',
                              obscureText: obscureNewPassword,
                              onToggle: () {
                                setState(() {
                                  obscureNewPassword = !obscureNewPassword;
                                });
                              },
                            ),
                            const SizedBox(height: 14),
                            _passwordField(
                              controller: confirmPasswordController,
                              hintText: 'Konfirmasi password baru',
                              obscureText: obscureConfirmPassword,
                              onToggle: () {
                                setState(() {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      isOldPasswordVerified
                          ? 'Pastikan password baru mudah kamu ingat dan tidak sama dengan password lama.'
                          : 'Masukkan password saat ini untuk memastikan bahwa akun ini benar milikmu.',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: AppColors.secondaryText,
                      ),
                    ),
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
              'Ganti Password',
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

  Widget _passwordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF8F8B89), fontSize: 16),
        filled: true,
        fillColor: const Color(0xFFF8F1EE),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.secondaryText,
          ),
        ),
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
          onPressed: isLoading
              ? null
              : isOldPasswordVerified
              ? _changePassword
              : _verifyOldPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orange,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  isOldPasswordVerified ? 'Ganti Password' : 'Cek Password',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
