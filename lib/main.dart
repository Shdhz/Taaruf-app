import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taaruf_app/routes/app_pages.dart';
import 'package:taaruf_app/routes/app_routes.dart';
import 'package:taaruf_app/theme/app_theme.dart';
// import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taaruf App',
      initialRoute: AppRoutes.home, // Root for route
      getPages: AppPages.pages,
      theme: AppTheme.lightTheme, // Apply the light theme with Poppins
      // themeMode: ThemeMode.system,
    );
  }
}
