import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class Beranda extends StatelessWidget {
  const Beranda({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Halaman Utama')),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false, // Menghilangkan label saat dipilih
        showUnselectedLabels: false, // Menghilangkan label saat tidak dipilih
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(BoxIcons.bxs_compass), label: ''),
          BottomNavigationBarItem(icon: Icon(BoxIcons.bxs_chat), label: ''),
        ],
      ),
    );
  }
}
