import 'package:flutter/material.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F4), // Warna background krem pucat
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Judul bergaya "Halo, Penyelamat!"
              const Text(
                "Selamat Datang!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Masuk untuk lanjut membantu kucing di sekitarmu.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              // Input Email
              _buildTextField(label: "Email", hint: "pengguna@email.com"),
              const SizedBox(height: 20),
              
              // Input Password
              _buildTextField(label: "Password", hint: "••••••••", isPassword: true),
              
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Lupa Password?", style: TextStyle(color: Color(0xFFFF7043))),
                ),
              ),
              const SizedBox(height: 24),
              
              // Tombol Login
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7043),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: const Text("Masuk", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              
              // Tombol Google (seperti di screenshot 3)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: Colors.grey, width: 0.5),
                  ),
                  icon: const Icon(Icons.g_mobiledata, size: 30),
                  label: const Text("Lanjut dengan Google", style: TextStyle(color: Colors.black87)),
                  onPressed: () {},
                ),
              ),
              
              const SizedBox(height: 40),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun? "),
                    GestureDetector(
                      onTap: () {
                        // Navigasi ke Register (logic Navigator.push)
                      },
                      child: TextButton(
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        }, 
                        child: Text("Daftar"),
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xFFFF7043),      // Text and icon color
                          backgroundColor: Colors.transparent, // Background color
                          padding: const EdgeInsets.all(1), // Internal spacing
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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