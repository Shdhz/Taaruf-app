// ignore_for_file: deprecated_member_use, avoid_print, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taaruf_app/main.dart';
import 'package:taaruf_app/routes/app_routes.dart';
import '../widget/bottomnav/bottom_nav.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String profileImageUrl = "https://picsum.photos/250?image=9";
  final String name = "Dhafa Alfareza";
  final int age = 31;
  final String gender = "male";
  final String job = "Programmer";

  bool isLoggingOut = false;

  @override
  void initState() {
    super.initState();
  }

  IconData get genderIcon => gender == "male" ? Icons.male : Icons.female;

  Future<void> _logout() async {
    try {
      // Tampilkan loading dialog
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Logout dengan batas waktu 5 detik
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId:
            '866202077954-akl5bgo01vhm27g4ih75f7mssg4om1it.apps.googleusercontent.com',
      );
      await supabase.auth.signOut().timeout(const Duration(seconds: 5));
      await googleSignIn.signOut();

      // Tutup loading dan navigasi ke login
      Get.back(); // Tutup dialog
      Get.snackbar(
        "Sukses",
        "Logout berhasil",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );

      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      // Tangani error dan tutup dialog
      Get.back(); // Tutup dialog jika error
      Get.snackbar(
        "Error",
        "Logout gagal: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            backgroundColor: Color.fromARGB(255, 109, 49, 182),
            elevation: 0,
            title: const Text(
              "Profile",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildListTile(
                  icon: Icons.person,
                  iconBg: Color(0xFFEDE7F6),
                  iconColor: Color(0xFF6A1B9A),
                  title: "Edit Profile",
                  subtitle: "Edit profile kamu",
                  // ignore: avoid_print
                  onTap: () => print("edit profil di klik"),
                ),
                _buildListTile(
                  icon: Icons.logout,
                  iconBg: Color(0xFFFFEBEE),
                  iconColor: Color(0xFFD32F2F),
                  title: "Sign Out",
                  subtitle: "Keluar dari aplikasi",
                  onTap: _logout,
                ),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNav(),
        ),
        if (isLoggingOut)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(18.0),
        bottomRight: Radius.circular(18.0),
      ),
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + kToolbarHeight,
        ),
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 109, 49, 182),
          border: Border.all(color: const Color(0x4D9E9E9E), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(genderIcon, color: Colors.white, size: 24),
                const SizedBox(width: 4),
                Text(
                  "$age, $job",
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _iconButtonBox(
                  icon: Icons.settings,
                  onPressed: () => print("Settings diklik"),
                ),
                const SizedBox(width: 14),
                _iconButtonBox(
                  icon: Icons.photo_camera,
                  onPressed: () => print("Kamera diklik"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.black38,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _iconButtonBox({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        alignment: Alignment.center,
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0x1FFCDFFF),
          border: Border.all(color: const Color(0x4D9E9E9E), width: 1),
        ),
        child: IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          color: Colors.white,
          iconSize: 24,
        ),
      ),
    );
  }
}
