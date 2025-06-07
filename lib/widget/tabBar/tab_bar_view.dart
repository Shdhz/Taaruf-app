import 'package:flutter/material.dart';

class EmptyTabContent extends StatelessWidget {
  final String title;
  final String message;
  final IconData image;

  const EmptyTabContent({
    super.key,
    required this.title,
    required this.message,
    required this.image,
    required List<String> tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(image, size: 80, color: Colors.deepPurple[200]),
            SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> tabs;
  final TabController controller;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.controller,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      tabs: tabs.map((t) => Tab(text: t)).toList(),
      indicatorColor: Colors.deepPurple,
      labelColor: Colors.deepPurple,
      unselectedLabelColor: Colors.grey,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
    );
  }
}
