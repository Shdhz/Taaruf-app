import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:taaruf_app/routes/app_pages.dart';
import 'package:taaruf_app/routes/app_routes.dart';
import 'package:taaruf_app/theme/app_theme.dart';
import 'package:taaruf_app/widget/bottomnav/BottomNavController.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
    String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    String supabaseKey = dotenv.env['SUPABASE_KEY'] ?? '';

    if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      throw Exception('Supabase credentials not found in .env file');
    }

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  } catch (e) {
    rethrow;
  }
  Get.put(BottomNavController(), permanent: true);
  runApp(MyApp());
}

final supabase = Supabase.instance.client;

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
