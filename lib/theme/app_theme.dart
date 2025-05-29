import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _appBarFontSize = 20.0;
  static const _appBarFontWeight = FontWeight.w600;
  static const _lightBackground = Color.fromARGB(255, 243, 243, 243);
  static const _lightAppBarColor = Color.fromARGB(255, 8, 8, 8);

  static TextTheme _textTheme(Brightness brightness) =>
      GoogleFonts.poppinsTextTheme(
        brightness == Brightness.light
            ? ThemeData.light().textTheme
            : ThemeData.dark().textTheme,
      );

  static AppBarTheme _appBarTheme(Color color) => AppBarTheme(
        titleTextStyle: GoogleFonts.poppins(
          fontSize: _appBarFontSize,
          fontWeight: _appBarFontWeight,
          color: color,
        ),
      );

  static ElevatedButtonThemeData _elevatedButtonTheme() =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      );

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: _lightBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    textTheme: _textTheme(Brightness.light),
    appBarTheme: _appBarTheme(_lightAppBarColor),
    elevatedButtonTheme: _elevatedButtonTheme(),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    textTheme: _textTheme(Brightness.dark),
    appBarTheme: _appBarTheme(Colors.white),
    elevatedButtonTheme: _elevatedButtonTheme(),
  );
}
