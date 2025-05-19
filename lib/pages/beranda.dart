import 'dart:math';

import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

import '../widget/bottomnav/bottom_nav.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  int selectedIndex = 0;
  Random random = Random();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Home'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Center(
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("kontol"),
            SizedBox(width: 20,),
            Text("MEMEK")
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(),
    );
  }
}



// Masih ngebug gabisa pindah ke halaman lain