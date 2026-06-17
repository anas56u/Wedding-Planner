import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/features/dashboard/presentation/pages/settings_screen.dart';
import 'package:provider_test/features/people_management/presentation/pages/home_screen.dart';
import 'package:provider_test/features/tasks/presentation/pages/tasks_screen.dart';
import 'package:provider_test/features/hospitality_staff/presentation/pages/hospitality_staff_screen.dart';
import '../widgets/welcome_banner.dart';
import '../widgets/service_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    // جلب البيانات من الـ Providers
    final dailyTip = context.watch<String>();

    // استخدام الـ Theme للوصول للألوان الموحدة بدلاً من Hardcoding
    final theme = Theme.of(context);

    return PopScope(
      canPop: false, // نمنع الخروج التلقائي الفوري
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        
        final bool shouldExit = await _showExitDialog(context) ?? false;
        
        // الخروج إذا وافق المستخدم
        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        // نعتمد على لون الخلفية المحدد في AppTheme
        appBar: AppBar(
          title: Text('dashboard.home'.tr()),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
        // استخدمنا SingleChildScrollView لمنع مشاكل الـ Overflow في الشاشات الصغيرة
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. البطاقة الترحيبية (تدمج العداد والنصيحة)
              WelcomeBanner(dailyTip: dailyTip, theme: theme),
      
              const SizedBox(height: 24),
      
              // 2. عنوان قسم الخدمات
              Text(
                'الخدمات الأساسية', // يفضل إضافتها لملف الترجمة لاحقاً
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary, // الكحلي الملكي
                ),
              ),
              const SizedBox(height: 16),
      
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0, // جعل البطاقات مربعة ومتناسقة
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // إيقاف التمرير الداخلي للشبكة
                children: [
                  ServiceCard(
                    title: 'dashboard.guests'.tr(),
                    icon: Icons.people_alt_rounded,
                    theme: theme,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    ),
                  ),
                  ServiceCard(
                    title: 'dashboard.preparations'.tr(),
                    icon: Icons.task_alt_rounded,
                    theme: theme,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TasksScreen(),
                      ),
                    ),
                  ),
                  ServiceCard(
                    title: 'dashboard.hospitality'.tr(),
                    icon: Icons.room_service_rounded,
                    theme: theme,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HospitalityStaffScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<bool?> _showExitDialog(BuildContext context) {
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.cardTheme.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'تأكيد الخروج',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          content: Text(
            'هل أنت متأكد أنك تريد الخروج من التطبيق؟',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('خروج'),
            ),
          ],
        );
      },
    );
  }
}
