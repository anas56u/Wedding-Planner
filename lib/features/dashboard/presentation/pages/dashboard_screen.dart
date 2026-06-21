import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider_test/features/profile/presentation/pages/settings_screen.dart';
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
    
    // 🌟 جلب بيانات المستخدم لعرض الاسم والعمر
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

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
              // 🌟 1. البطاقة الشخصية (الاسم والعمر)
              if (user != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.85),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // صورة البروفايل (الحرف الأول)
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.secondary,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // النصوص (الاسم والعمر)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'dashboard.welcome_prefix'.tr(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 14,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'dashboard.user_age'.tr(namedArgs: {'age': user.age.toString()}),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 2. البطاقة الترحيبية (تدمج العداد والنصيحة)
              WelcomeBanner(dailyTip: dailyTip, theme: theme),
      
              const SizedBox(height: 24),
      
              // 3. عنوان قسم الخدمات
              Text(
                'dashboard.essential_services'.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary, // الكحلي الملكي
                ),
              ),
              const SizedBox(height: 16),
      
              // 4. شبكة الخدمات (GridView)
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0, // جعل البطاقات مربعة ومتناسقة
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // إيقاف التمرير الداخلي للشبكة
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
            'dashboard.exit_confirm_title'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          content: Text(
            'dashboard.exit_confirm_message'.tr(),
            style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('common.cancel'.tr(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('dashboard.exit_button'.tr()),
            ),
          ],
        );
      },
    );
  }
}