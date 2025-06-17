import 'package:get/get.dart';
import 'package:taaruf_app/auth/login.dart';
import 'package:taaruf_app/pages/beranda.dart';
import 'package:taaruf_app/pages/carousel_home.dart';
import 'package:taaruf_app/pages/detail_profile/detail_profile.dart';
import 'package:taaruf_app/pages/detail_profile_calon.dart';
import '../pages/history.dart';
import '../pages/profile.dart';
import '../auth/register.dart';
import '../pages/find_couple.dart';
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
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: AppRoutes.homepage,
      page: () => const Beranda(),
    ),
    GetPage(
      name: AppRoutes.explore,
      page: () => const FindCouple(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const Profile(),
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => const History(),
    ),
    GetPage(
      name: AppRoutes.detailProfile,
      page: () => const DetailProfile()
    ),
    GetPage(
      name: AppRoutes.detailProfileCalon,
      page: () => const DetailProfileCalon()
    )
  ];
}