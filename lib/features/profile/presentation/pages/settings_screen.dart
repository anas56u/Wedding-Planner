import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider_test/features/auth/presentation/pages/login_screen.dart';
import 'package:provider_test/features/profile/presentation/pages/privacy_policy_screen.dart';
import '../widgets/profile_header.dart';
import 'package:provider_test/features/dashboard/presentation/widgets/section_title.dart';
import '../widgets/settings_card.dart';
import '../widgets/language_dropdown.dart';
import '../widgets/switch_option.dart';
import 'package:provider_test/features/dashboard/presentation/widgets/action_option.dart';
import '../widgets/settings_divider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // مفتاح الإشعارات يعمل شكلياً فقط بـ setState على مستوى الشاشة
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLocale = context.locale.languageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('settings.title'.tr()), // مترجم بالكامل
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ProfileHeader(theme: theme),
          const SizedBox(height: 32),

          // قسم الإعدادات العامة
          SectionTitle(title: 'settings.general_section'.tr(), theme: theme),
          const SizedBox(height: 12),
          SettingsCard(
            theme: theme,
            children: [
              LanguageDropdown(
                theme: theme,
                currentLocale: currentLocale,
                onChanged: (String? newValue) async {
                  if (newValue != null && newValue != currentLocale) {
                    await context.setLocale(Locale(newValue));
                    setState(() {});
                  }
                },
              ),
              SettingsDivider(theme: theme),
              SwitchOption(
                theme: theme,
                title: 'settings.notifications'.tr(),
                icon: Icons.notifications_active_outlined,
                value: _notificationsEnabled,
                onChanged: (val) {
                  // تحديث الواجهة بشكل موضعي فقط دون عمليات خلفية
                  setState(() => _notificationsEnabled = val);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // قسم عن التطبيق
          SectionTitle(title: 'settings.about_section'.tr(), theme: theme),
          const SizedBox(height: 12),
          SettingsCard(
            theme: theme,
            children: [
              ActionOption(
                theme: theme,
                title: 'settings.privacy_policy'.tr(),
                icon: Icons.privacy_tip_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
              SettingsDivider(theme: theme),
             ActionOption(
                theme: theme,
                title: 'settings.logout'.tr(),
                icon: Icons.logout_rounded,
                isDestructive: true,
                onTap: () async {
                  // 1. إظهار رسالة تأكيد للمستخدم
                  final bool? confirmLogout = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        backgroundColor: theme.cardTheme.color,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        title: Row(
                          children: [
                            Icon(Icons.logout_rounded, color: Colors.red.shade400),
                            const SizedBox(width: 12),
                            Text(
                              'تسجيل الخروج', // يمكنك تحويلها لـ 'settings.logout'.tr()
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          'هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(false),
                            child: Text(
                              'common.cancel'.tr(),
                              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => Navigator.of(dialogContext).pop(true),
                            child: const Text('تأكيد الخروج'),
                          ),
                        ],
                      );
                    },
                  );

                  // 2. إذا وافق المستخدم على الخروج
                  if (confirmLogout == true && context.mounted) {
                    // استدعاء دالة تسجيل الخروج من الـ Provider
                    await context.read<AuthProvider>().logout();

                    // التوجيه إلى شاشة تسجيل الدخول ومسح كل الشاشات السابقة من الذاكرة
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false, // مسح السجل بالكامل
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
