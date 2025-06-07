import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../routes/app_routes.dart';

class BottomNavController extends GetxController {
  RxInt currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;

    // Logic controller for navigation
    switch (index) {
      case 0:
        Get.offNamed(AppRoutes.beranda);
        break;
      case 1:
        Get.offNamed(AppRoutes.explore);
        break;
      case 2:
        Get.offNamed(AppRoutes.history);
        break;
      case 3:
        Get.offNamed(AppRoutes.profile);
        break;
    }
  }
}

class CustomBottomNav extends StatelessWidget {
  CustomBottomNav({super.key});

  final BottomNavController controller = Get.put(BottomNavController(), permanent: true);
  final Duration _animationDuration = const Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeIndex,
        backgroundColor: Colors.white,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: _buildAnimatedIcon(
              context,
              BoxIcons.bx_home,
              BoxIcons.bx_home,
              0,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildAnimatedIcon(
              context,
              BoxIcons.bx_compass,
              BoxIcons.bx_compass,
              1,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildAnimatedIcon(
              context,
              BoxIcons.bx_history,
              BoxIcons.bx_history,
              2,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildAnimatedIcon(
              context,
              BoxIcons.bx_user,
              BoxIcons.bx_user,
              3,
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon(
    BuildContext context,
    IconData inactiveIcon,
    IconData activeIcon,
    int index,
  ) {
    bool isActive = controller.currentIndex.value == index;

    return AnimatedContainer(
      duration: _animationDuration,
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            isActive
                ? Theme.of(context).primaryColor.withOpacity(0.15)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedCrossFade(
        firstChild: Icon(inactiveIcon, size: 30, color: Colors.grey),
        secondChild: Icon(
          activeIcon,
          size: 30,
          color: Theme.of(context).primaryColor,
        ),
        crossFadeState:
            isActive ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: _animationDuration,
      ),
    );
  }
}
