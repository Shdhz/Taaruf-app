import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taaruf_app/widget/card/card_calon_taaruf.dart';

import '../widget/bottomnav/bottom_nav.dart';

class FindCouple extends StatefulWidget {
  const FindCouple({super.key});

  @override
  State<FindCouple> createState() => _FindCoupleState();
}

class _FindCoupleState extends State<FindCouple> {
  // DATA CONFIGURATION - Ubah data di sini
  final String appTitle = "Explore";
  final IconData filterIcon = Icons.tune;
  final double filterIconSize = 28.0;

  // Filter buttons configuration
  final List<Map<String, dynamic>> filterButtons = [
    {
      'text': 'Trending 🔥',
      'isActive': true,
      'action': 'trending',
      'message': 'Trending button pressed',
    },
    {
      'text': 'Likes You',
      'isActive': false,
      'action': 'likes',
      'message': 'Likes You button pressed',
    },
    {
      'text': 'Visited You',
      'isActive': false,
      'action': 'visited',
      'message': 'Visited you button pressed',
    },
  ];

  // Colors configuration
  final Color activeButtonColor = Colors.deepPurple;
  final Color inactiveButtonColor = Color.fromARGB(255, 247, 243, 253);
  final Color activeTextColor = Color.fromARGB(255, 255, 255, 255);
  final Color inactiveTextColor = Color.fromARGB(255, 7, 7, 7);
  final Color appBarBackgroundColor = Color.fromARGB(255, 255, 255, 255);
  final Color appBarTitleColor = Colors.deepPurple;
  final Color filterContainerColor = Colors.white;

  // Text styling
  final double buttonFontSize = 14.0;
  final FontWeight buttonFontWeight = FontWeight.w500;
  final double appBarElevation = 0.0;

  // Spacing and padding
  final EdgeInsets filterContainerPadding = EdgeInsets.symmetric(
    vertical: 20,
    horizontal: 15,
  );
  final EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 10,
  );
  final EdgeInsets iconButtonPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );
  final double buttonBorderRadius = 12.0;
  final Duration snackBarDuration = Duration(seconds: 1);
  // END DATA CONFIGURATION

  int selectedFilterIndex = 0;

  void _handleFilterTap(int index) {
    setState(() {
      selectedFilterIndex = index;
      // Update active status
      for (int i = 0; i < filterButtons.length; i++) {
        filterButtons[i]['isActive'] = i == index;
      }
    });

    // Show snackbar message
    final message = filterButtons[index]['message'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: snackBarDuration),
    );
  }

  void _handleFilterIconTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filter button pressed'),
        duration: snackBarDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: _buildAppBar(),
      body: Column(
        children: [_buildFilterContainer(), _buildCalonTaarufSection()],
      ),
      bottomNavigationBar: CustomBottomNav(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: Text(appTitle, style: TextStyle(color: appBarTitleColor)),
      backgroundColor: appBarBackgroundColor,
      elevation: appBarElevation,
      scrolledUnderElevation: 4,
      surfaceTintColor: Colors.transparent,
      actions: [
        IconButton(
          padding: iconButtonPadding,
          onPressed: _handleFilterIconTap,
          icon: Icon(filterIcon, size: filterIconSize),
        ),
      ],
    );
  }

  Widget _buildFilterContainer() {
    return Container(
      padding: filterContainerPadding,
      decoration: BoxDecoration(color: filterContainerColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          filterButtons.length,
          (index) => _buildFilterButton(index),
        ),
      ),
    );
  }

  Widget _buildFilterButton(int index) {
    final button = filterButtons[index];
    final isActive = button['isActive'];

    return TextButton(
      onPressed: () => _handleFilterTap(index),
      style: TextButton.styleFrom(
        backgroundColor: isActive ? activeButtonColor : inactiveButtonColor,
        padding: buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
        ),
      ),
      child: Text(
        button['text'],
        style: GoogleFonts.poppins(
          fontSize: buttonFontSize,
          color: isActive ? activeTextColor : inactiveTextColor,
          fontWeight: buttonFontWeight,
        ),
      ),
    );
  }

  Widget _buildCalonTaarufSection() {
    return Expanded(child: const CalonTaarufWidget());
  }
}
