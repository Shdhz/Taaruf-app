// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../routes/app_routes.dart';
import 'BottomNavController.dart'; // pastikan import controller

class CustomBottomNav extends StatelessWidget {
  CustomBottomNav({super.key});

  final BottomNavController controller = Get.put(
    BottomNavController(),
    permanent: true,
  );

  final Duration _animationDuration = const Duration(milliseconds: 400);

  final List<String> _routes = [
    AppRoutes.beranda,
    AppRoutes.explore,
    AppRoutes.history,
    AppRoutes.profile,
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: controller.currentIndex.value,
        onTap: (index) {
          // Step 1: Update index
          controller.changeIndex(index);

          // Step 2: Tunda navigasi satu frame
          Future.microtask(() => Get.offNamed(_routes[index]));
        },
        backgroundColor: Colors.white,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: _buildAnimatedIcon(context, BoxIcons.bx_home, 0),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildAnimatedIcon(context, BoxIcons.bx_compass, 1),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildAnimatedIcon(context, BoxIcons.bx_history, 2),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildAnimatedIcon(context, BoxIcons.bx_user, 3),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon(
    BuildContext context,
    IconData iconData,
    int index,
  ) {
    bool isActive = controller.currentIndex.value == index;

    return AnimatedContainer(
      duration: _animationDuration,
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).primaryColor.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedCrossFade(
        firstChild: Icon(iconData, size: 30, color: Colors.grey),
        secondChild: Icon(iconData, size: 30, color: Theme.of(context).primaryColor),
        crossFadeState:
            isActive ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: _animationDuration,
      ),
    );
  }
}
