import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF6EBDD),
    primaryColor: Colors.brown,

    textTheme: GoogleFonts.ubuntuTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontWeight: FontWeight.w400),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.brown,
      unselectedItemColor: Colors.black54,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF8C7058),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
