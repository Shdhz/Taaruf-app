import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../widget/carousel/carousel_home_screen.dart';

class CarouselHome extends StatefulWidget {
  const CarouselHome({super.key});

  @override
  State<CarouselHome> createState() => _CarouselHomeState();
}

class _CarouselHomeState extends State<CarouselHome> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> images = [
    'images/jodoh_halal.png',
    'images/gambar.jpg',
    'images/logo.png',
  ];

  final List<String> titleList = [
    'Temukan Jodoh Halalmu',
    'Kenali Lebih Dekat',
    'Mulai Perjalanan Cinta',
  ];

  final List<String> descList = [
    'Bersama Taaruf App, proses taaruf jadi lebih aman dan nyaman.',
    'Bangun komunikasi yang sehat dan sesuai syariat.',
    'Ayo mulai langkah pertamamu menuju keluarga sakinah.',
  ];

  void goTologin(BuildContext context) {
    Get.offNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return CarouselCard(
              index: index,
              currentIndex: _currentIndex,
              images: images,
              titleList: titleList,
              descList: descList,
              onSkip: () => goTologin(context),
              onNext: () {
                if (_currentIndex == images.length - 1) {
                  goTologin(context);
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
