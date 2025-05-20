import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        title: Text('Explore', style: TextStyle(color: Colors.deepPurple)),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        actions: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onPressed: () {},
            icon: Icon(Icons.tune, size: 28),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              // container filter calon
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Trending 🔥',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 247, 243, 253),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Likes You',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color.fromARGB(255, 7, 7, 7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 247, 243, 253),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Visited You',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color.fromARGB(255, 7, 7, 7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Widget Calon taaruf
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(),
    );
  }
}
