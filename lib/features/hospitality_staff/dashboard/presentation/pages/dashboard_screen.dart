import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/features/dashboard/presentation/widgets/service_card.dart';
import 'package:provider_test/features/dashboard/presentation/widgets/welcome_banner.dart';
import 'package:provider_test/features/hospitality_staff/dashboard/presentation/pages/settings_screen.dart';
import 'package:provider_test/features/people_management/presentation/pages/home_screen.dart';
import 'package:provider_test/features/tasks/presentation/pages/tasks_screen.dart';
import 'package:provider_test/features/hospitality_staff/presentation/pages/hospitality_staff_screen.dart';

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

    return Scaffold(
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

            // 3. شبكة الخدمات (GridView)
            // استخدمنا shrinkWrap لنسمح للـ GridView بالعمل داخل ScrollView
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
    );
  }
}
