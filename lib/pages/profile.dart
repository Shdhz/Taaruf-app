import 'package:flutter/material.dart';
import '../widget/bottomnav/bottom_nav.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data - nanti diganti dari database
    final String profileImageUrl = "https://picsum.photos/250?image=9";
    final String name = "Dhafa Alfareza";
    final int age = 31;
    final String gender = "male";
    final String job = "Programmer";

    IconData genderIcon = gender == "male" ? Icons.male : Icons.female;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 109, 49, 182),
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipRRect(
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
                          onPressed: () {
                            print("Settings diklik");
                          },
                        ),
                        const SizedBox(width: 14),
                        _iconButtonBox(
                          icon: Icons.photo_camera,
                          onPressed: () {
                            print("Kamera diklik");
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Container(
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
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE7F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF6A1B9A),
                    size: 20,
                  ),
                ),
                title: const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                subtitle: const Text(
                  "Edit profile kamu",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black38,
                ),
                onTap: () => print("edit profil di klik"),
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Color(0xFFD32F2F),
                    size: 20,
                  ),
                ),
                title: const Text(
                  "Sign Out",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                subtitle: const Text(
                  "Keluar dari aplikasi",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black38,
                ),
                onTap: () => print("Sign out di klik"),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: CustomBottomNav(),
    );
  }
}

// komponen icon btn
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
