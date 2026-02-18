import 'dart:io';
import 'package:bbs_gudang/features/auth/presentation/pages/login_page.dart';
import 'package:bbs_gudang/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Memanggil fetchUserDetails saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchUserDetails();
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Kamera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan Consumer untuk mendengarkan perubahan state (loading/error/user)
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        return Scaffold(
          backgroundColor: Colors.white,
          // Menampilkan Loading Overlay jika sedang fetch data
          body: authProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 280,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF50),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                            ),
                          ),
                          // Positioned(
                          //   top: 50,
                          //   left: 10,
                          //   child: IconButton(
                          //     icon: const Icon(
                          //       Icons.arrow_back,
                          //       color: Colors.white,
                          //     ),
                          //     onPressed: () => Navigaor,
                          //   ),
                          // ),
                          Positioned(
                            top: 60,
                            left: 0,
                            right: 0,
                            child: const Center(
                              child: Text(
                                "Profile",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 30,
                            left: 0,
                            right: 0,
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: _showPickerOptions,
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 60,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                          radius: 56,
                                          backgroundColor: const Color(
                                            0xFFE0E0E0,
                                          ),
                                          backgroundImage: _imageFile != null
                                              ? FileImage(_imageFile!)
                                              : null,
                                          child: _imageFile == null
                                              ? const Icon(
                                                  Icons.camera_alt,
                                                  size: 40,
                                                  color: Colors.grey,
                                                )
                                              : null,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundColor: const Color(
                                            0xFF66BB6A,
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  user?.name ?? "No Name",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Profil",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Divider(height: 30),
                            _buildProfileItem(
                              icon: Icons.person_outline,
                              label: user?.username ?? user?.name ?? "-",
                            ),
                            _buildProfileItem(
                              icon: Icons.mail_outline,
                              label: user?.username ?? "Email belum diatur",
                            ),
                            _buildProfileItem(
                              icon: Icons.phone_outlined,
                              label: user?.desc ?? "No. Telepon tidak ada",
                            ),
                            _buildProfileItem(
                              icon: Icons.lock_outline,
                              label: "******",
                            ),
                            const SizedBox(height: 30),
                            InkWell(
                              onTap: () => _showLogoutDialog(context),
                              child: const Row(
                                children: [
                                  Icon(Icons.logout, color: Colors.redAccent),
                                  SizedBox(width: 15),
                                  Text(
                                    "Logout",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildProfileItem({required IconData icon, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text(
              "Ya, Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
