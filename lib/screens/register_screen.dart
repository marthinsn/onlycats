import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F4), // Warna background krem pucat
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Pusatkan elemen profil
            children: [
              const SizedBox(height: 20),
              
              // Tombol Back (Opsional, agar mudah kembali ke Login)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const SizedBox(height: 20),
              
              // --- BAGIAN FOTO PROFIL (Serasi dengan image_1.png) ---
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFFFFEBEA), // Warna blush pink muda
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 60,
                        color: const Color(0xFFFF7043).withOpacity(0.6),
                      ),
                    ),
                  ),
                  // Tombol Edit Kecil (seperti di image_1.png)
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7043),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              // --- FORM INPUT ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  const Text(
                    "Buat Akun Baru",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Lengkapi data untuk menjadi Pahlawan Kucing.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // Input Nama Lengkap
                  _buildTextField(label: "Nama Lengkap", hint: "Nama Pengguna"),
                  const SizedBox(height: 20),

                  // Input Email
                  _buildTextField(label: "Email", hint: "pengguna@email.com"),
                  const SizedBox(height: 20),
                  
                  // Input Password
                  _buildTextField(label: "Password", hint: "Minimum 8 karakter", isPassword: true),
                  const SizedBox(height: 20),

                  // Input Konfirmasi Password
                  _buildTextField(label: "Konfirmasi Password", hint: "Ulangi password", isPassword: true),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // --- TOMBOL DAFTAR ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7043),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // Logic pendaftaran
                  },
                  child: const Text("Daftar Sekarang", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
              
              // Link ke Login
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Sudah punya akun? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Kembali ke halaman Login
                      },
                      child: TextButton(
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        }, 
                        child: Text("Masuk"),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk membuat Input Field (sama dengan di Login)
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
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
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