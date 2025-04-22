import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taaruf_app/auth/login.dart';
import 'package:taaruf_app/home/carousel_home.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Taaruf App",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const CarouselHome(),
        '/login': (context) => const LoginPage(), // Pastikan class LoginPage sudah dibuat
      },
    );
  }
}
