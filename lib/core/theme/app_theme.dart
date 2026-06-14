import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
 
  static const Color primaryNavy = Color(0xFF1A2A3A); // كحلي ملكي راقي
  static const Color accentRoseGold = Color(0xFFD4AF37); // ذهبي/روز جولد للمناسبات
  static const Color backgroundCream = Color(0xFFF9F9F6); // خلفية كريمية مريحة للعين (Off-White)
  static const Color successGreen = Color(0xFF4CAF50); // للضيوف الحاضرين
  static const Color pendingOrange = Color(0xFFFF9800); // للضيوف في الانتظار

  // 2. بناء الـ ThemeData الذي سيتم حقنه في التطبيق
  static ThemeData get lightTheme {
    return ThemeData(
      // استخدام لون الخلفية المريح
      scaffoldBackgroundColor: backgroundCream,
      
      // إعدادات الـ AppBar (الشريط العلوي)
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundCream,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryNavy),
        // استخدام خط Cairo للعناوين
        titleTextStyle: GoogleFonts.cairo(
          color: primaryNavy,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // إعدادات البطاقات (Cards)
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: primaryNavy.withOpacity(0.1), // ظل خفيف جداً وأنيق
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // حواف دائرية عصرية
        ),
      ),

      // إعدادات الأزرار (ElevatedButton)
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

      // توحيد الخطوط في التطبيق بأكمله ليصبح Cairo
      textTheme: GoogleFonts.cairoTextTheme().apply(
        bodyColor: primaryNavy,
        displayColor: primaryNavy,
      ),

      // إعدادات الألوان العامة للتطبيق
      colorScheme: const ColorScheme.light(
        primary: primaryNavy,
        secondary: accentRoseGold,
        surface: Colors.white,
      ),
    );
  }
}