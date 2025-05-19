import 'package:flutter/material.dart';

import '../widget/bottomnav/bottom_nav.dart';

class FindCouple extends StatefulWidget {
  const FindCouple({super.key});

  @override
  State<FindCouple> createState() => _FindCoupleState();
}

class _FindCoupleState extends State<FindCouple> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Explore'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Text("Explore"),
      bottomNavigationBar: CustomBottomNav(),
    );
  }
}