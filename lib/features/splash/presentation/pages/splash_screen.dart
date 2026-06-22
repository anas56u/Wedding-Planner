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
    

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();


    _initializeAppAndNavigate();
  }

  Future<void> _initializeAppAndNavigate() async {

    await Future.delayed(const Duration(seconds: 2));


    if (!mounted) return;


    final authProvider = context.read<AuthProvider>();
    await authProvider.checkAuthStatus();

    if (!mounted) return;


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

    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

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
                  color: AppTheme.backgroundCream,
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
              const SizedBox(height: 40),

              const CircularProgressIndicator(
                color: AppTheme.accentRoseGold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}