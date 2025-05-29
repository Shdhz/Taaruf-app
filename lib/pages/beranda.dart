import 'package:flutter/material.dart';
// import 'package:icons_plus/icons_plus.dart';

import '../theme/app_text_style.dart';
import '../widget/bottomnav/bottom_nav.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: TextStyle(color: Colors.deepPurple)),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: ElevatedButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'CV Taaruf',
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          child: Column(
            children: [
              // Profile widget
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    buildClickableOvalImage(
                      imagePath: 'images/download.jpg',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gambar berhasil kamu klik'),
                          ),
                        );
                      },
                      size: 80,
                      margin: const EdgeInsets.all(10),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Agus Rohmat', style: AppTextStyle.h3),
                          const SizedBox(height: 4),
                          Text(
                            'agus@gmail.com',
                            style: AppTextStyle.bodyMedium.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    252,
                                    243,
                                    218,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Gold Member',
                                      style: AppTextStyle.bodySmall.copyWith(
                                        color: const Color.fromARGB(
                                          255,
                                          24,
                                          24,
                                          24,
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
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quick Button container
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 20,
                  children: [
                    _buildMenuItem(Icons.settings, 'Pengaturan', () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Pengaturan berhasil kamu klik"),
                        ),
                      );
                    }),
                    _buildMenuItem(Icons.help, 'Bantuan', () {}),
                    _buildMenuItem(Icons.report, 'Laporkan', () {}),
                    _buildMenuItem(Icons.person, 'Profil', () {}),
                    _buildMenuItem(Icons.logout, 'Keluar', () {}),
                    _buildMenuItem(Icons.auto_stories, 'Cara kerja', () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(),
    );
  }
}

// Menu item
Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: SizedBox(
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color.fromARGB(255, 239, 236, 245),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 168, 124, 243),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    ),
  );
}

// Profil
Widget buildClickableOvalImage({
  required String imagePath,
  required VoidCallback onTap,
  double size = 70.0,
  EdgeInsetsGeometry margin = const EdgeInsets.all(10.0),
  Color borderColor = Colors.grey,
  double borderWidth = 1.0,
}) {
  final resolvedBorderColor = Colors.grey.shade300;

  return Container(
    margin: margin, // Margin di luar area yang bisa diklik dan oval
    width: size, // Lebar total untuk area oval
    height: size, // Tinggi total untuk area oval
    child: ClipOval(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              border: Border.all(
                color: resolvedBorderColor,
                width: borderWidth,
              ),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
