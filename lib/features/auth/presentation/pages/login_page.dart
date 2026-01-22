import 'package:flutter/material.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // Menggunakan SafeArea agar tidak terpotong status bar
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Masuk ke akun",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              // Ilustrasi
              Center(
                child: Image.asset(
                  "lib/assets/login1.png",
                  height: 200, // Sesuaikan ukuran
                ),
              ),
              const SizedBox(height: 40),
              const LoginForm(),
              const SizedBox(height: 40),
              // Teks Register di bagian bawah
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun? "),
                  GestureDetector(
                    onTap: () {
                      // Navigasi ke Register
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        color: Color(0xFF4CAF50), // Warna hijau sesuai gambar
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
