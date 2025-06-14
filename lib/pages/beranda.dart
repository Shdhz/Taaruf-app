import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taaruf_app/main.dart';
import 'package:taaruf_app/routes/app_routes.dart';
import 'package:taaruf_app/widget/user_profile_avatar.dart';
// import 'package:icons_plus/icons_plus.dart';

import '../theme/app_text_style.dart';
import '../widget/bottomnav/bottom_nav.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  // DATA CONFIGURATION - Ubah data di sini
  String? profileImagePath;
  String? userName;
  String? userEmail;
  final String membershipType = "Gold Member";
  final Color membershipBadgeColor = Color.fromARGB(255, 252, 243, 218);
  final String appTitle = "Home";
  final String buttonText = "CV Taaruf";

  // Menu Configuration
  final List<Map<String, dynamic>> menuConfig = [
    {
      'icon': Icons.settings,
      'label': 'Pengaturan',
      'action': 'settings',
      'enabled': true,
    },
    {'icon': Icons.help, 'label': 'Bantuan', 'action': 'help', 'enabled': true},
    {
      'icon': Icons.report,
      'label': 'Laporkan',
      'action': 'report',
      'enabled': true,
    },
    {
      'icon': Icons.person,
      'label': 'Profil',
      'action': 'profile',
      'enabled': true,
    },
    {
      'icon': Icons.logout,
      'label': 'Keluar',
      'action': 'logout',
      'enabled': true,
    },
    {
      'icon': Icons.auto_stories,
      'label': 'Cara kerja',
      'action': 'how_to',
      'enabled': true,
    },
  ];
  final String settingsClickMessage = "Pengaturan berhasil kamu klik";
  String? getPublicImageUrl(String storagePath) {
    try {
      if (storagePath.isEmpty) {
        return null;
      }

      final publicUrl = supabase.storage
          .from('user-assets')
          .getPublicUrl(storagePath);

      if (publicUrl.isEmpty || !publicUrl.startsWith('http')) {
        return null;
      }

      return publicUrl;
    } catch (e) {
      return null;
    }
  }
  // END DATA CONFIGURATION

  int selectedIndex = 0;

  void _handleMenuTap(String action) {
    switch (action) {
      case 'settings':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(settingsClickMessage)));
        break;
      case 'help':
        // Navigate to help page
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$action berhasil diklik")));
        break;
      case 'report':
        // Navigate to report page
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$action berhasil diklik")));
        break;
      case 'profile':
        // Navigate to profile page
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$action berhasil diklik")));
        break;
      case 'logout':
        // Handle logout
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$action berhasil diklik")));
        break;
      case 'how_to':
        // Navigate to how-to page
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$action berhasil diklik")));
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Aksi tidak dikenali")));
    }
  }

  void getCurrentUser() async {
    final user = supabase.auth.currentUser;

    if (user != null) {
      userEmail = user.email;
      userName = user.userMetadata?['name'] ?? 'Pengguna';
    } else {
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle, style: TextStyle(color: Colors.deepPurple)),
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
              child: Text(
                buttonText,
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
                    UserProfileAvatar(
                      size: 80,
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.detailProfile,
                          arguments: {
                            'photoUrl': null,
                          }, // atau isi kalau sudah tahu URL-nya
                        );
                      },
                    ),

                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName ?? 'Loading...',
                            style: AppTextStyle.h3,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userEmail ?? '-',
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
                                  color: membershipBadgeColor,
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
                                      membershipType,
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
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 20,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: menuConfig.length,
                  itemBuilder: (context, index) {
                    final menu = menuConfig[index];
                    return _buildMenuItem(
                      menu['icon'],
                      menu['label'],
                      menu['enabled']
                          ? () => _handleMenuTap(menu['action'])
                          : null,
                    );
                  },
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
Widget _buildMenuItem(IconData icon, String label, VoidCallback? onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Opacity(
      opacity: onTap != null ? 1.0 : 0.5,
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
                image: NetworkImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
