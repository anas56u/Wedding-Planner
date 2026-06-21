import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/core/theme/app_theme.dart';
import 'package:provider_test/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider_test/features/auth/presentation/pages/login_screen.dart';
import 'package:provider_test/features/dashboard/presentation/pages/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // إعداد أنيميشن (Fade In) لظهور العناصر بشكل ناعم
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // مدة الأنيميشن ثانية ونصف
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    // تشغيل دالة التحقق من التوجيه
    _initializeAppAndNavigate();
  }

  Future<void> _initializeAppAndNavigate() async {
    // 1. إعطاء وقت للأنيميشن ليكتمل ولإظهار الشاشة بشكل جميل للمستخدم
    await Future.delayed(const Duration(seconds: 2));

    // تأكد أن الشاشة ما زالت موجودة في شجرة الـ Widgets لتجنب أخطاء الـ Context
    if (!mounted) return;

    // 2. فحص حالة المصادقة (هل المستخدم مسجل دخول أم لا)
    final authProvider = context.read<AuthProvider>();
    await authProvider.checkAuthStatus(); 

    if (!mounted) return;

    // 3. التوجيه بناءً على حالة تسجيل الدخول
    if (authProvider.isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    // أفضل الممارسات: يجب دائماً التخلص من الـ AnimationController لمنع تسريب الذاكرة (Memory Leak)
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استخدام الألوان المتناسقة من AppTheme
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy, 
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // يمكنك لاحقاً استبدال الأيقونة بـ Image.asset إذا توفر لديك لوجو
              const Icon(
                Icons.favorite_rounded, 
                size: 80, 
                color: AppTheme.accentRoseGold,
              ),
              const SizedBox(height: 20),
              Text(
                'splash.app_title'.tr(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.backgroundCream, // لون يتناسب مع الكحلي
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'splash.app_subtitle'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.accentRoseGold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}