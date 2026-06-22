import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
 
  static const Color primaryNavy = Color(0xFF1A2A3A);
  static const Color accentRoseGold = Color(0xFFD4AF37);
  static const Color backgroundCream = Color(0xFFF9F9F6);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color pendingOrange = Color(0xFFFF9800);
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: backgroundCream,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundCream,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryNavy),
        titleTextStyle: GoogleFonts.cairo(
          color: primaryNavy,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: primaryNavy.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      textTheme: GoogleFonts.cairoTextTheme().apply(
        bodyColor: primaryNavy,
        displayColor: primaryNavy,
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryNavy,
        secondary: accentRoseGold,
        surface: Colors.white,
      ),
    );
  }
}