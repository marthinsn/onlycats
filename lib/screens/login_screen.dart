import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'forgot_password_screen.dart';
import '../widgets/cat_loading.dart';
import 'register_screen.dart';
import '../services/admin_service.dart';
import '../services/notification_listener_service.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isPasswordHidden = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Email dan password wajib diisi.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      _handleLoginSuccess(credential);
    } on FirebaseAuthException catch (e) {
      String message = 'Login gagal. Silakan coba lagi.';

      if (e.code == 'user-not-found') {
        message = 'Email belum terdaftar.';
      } else if (e.code == 'wrong-password') {
        message = 'Password salah.';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid.';
      } else if (e.code == 'invalid-credential') {
        message = 'Email atau password salah.';
      } else if (e.code == 'network-request-failed') {
        message = 'Koneksi internet bermasalah.';
      } else if (e.code == 'too-many-requests') {
        message = 'Terlalu banyak percobaan login. Coba lagi nanti.';
      }

      _showMessage(message);
    } catch (e) {
      _showMessage('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await _authService.signInWithGoogle();

      if (credential != null) {
        _handleLoginSuccess(credential);
      }
    } on FirebaseAuthException catch (e) {
      _showMessage('Login Google gagal: ${e.message}');
    } catch (e) {
      _showMessage('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleLoginSuccess(UserCredential credential) {
    if (!mounted) return;

    final user = credential.user;

    if (user == null) {
      _showMessage('Login gagal. User tidak ditemukan.');
      return;
    }

    final loggedInEmail = user.email?.toLowerCase() ?? '';
    final isAdmin = isAdminEmail(loggedInEmail);

    // Jika admin, dengarkan notifikasi khusus 'admin'
    // Jika user biasa, dengarkan notifikasi berdasarkan uid mereka
    NotificationListenerService.startListening(isAdmin ? 'admin' : user.uid);

    if (isAdmin) {
      Navigator.pushReplacementNamed(context, '/admin/home');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _goToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ForgotPasswordScreen(initialEmail: _emailController.text.trim()),
      ),
    );
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              const Text(
                'Selamat Datang!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Masuk untuk lanjut membantu kucing di sekitarmu.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 40),

              _buildTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'pengguna@email.com',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: '••••••••',
                isPassword: true,
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLoading ? null : _goToForgotPassword,
                  child: const Text(
                    'Lupa Password?',
                    style: TextStyle(color: Color(0xFFFF7043)),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7043),
                    disabledBackgroundColor: const Color(
                      0xFFFF7043,
                    ).withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CatLoading(size: 30)
                      : const Text(
                          'Masuk',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: const BorderSide(color: Colors.grey, width: 0.5),
                  ),
                  icon: const Icon(Icons.g_mobiledata, size: 30),
                  label: const Text(
                    'Lanjut dengan Google',
                    style: TextStyle(color: Colors.black87),
                  ),
                  onPressed: _isLoading ? null : _loginWithGoogle,
                ),
              ),

              const SizedBox(height: 40),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum punya akun? '),
                    TextButton(
                      onPressed: _isLoading ? null : _goToRegister,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFF7043),
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.all(1),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Daftar'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          obscureText: isPassword ? _isPasswordHidden : false,
          keyboardType: keyboardType,
          textInputAction: isPassword
              ? TextInputAction.done
              : TextInputAction.next,
          onSubmitted: (_) {
            if (isPassword && !_isLoading) {
              _login();
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordHidden
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordHidden = !_isPasswordHidden;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
