import 'package:get/get.dart';
import 'package:taaruf_app/auth/login.dart';
import 'package:taaruf_app/pages/beranda.dart';
import 'package:taaruf_app/pages/carousel_home.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const CarouselHome(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: AppRoutes.beranda,
      page: () => const Beranda(),
    ),
  ];
}