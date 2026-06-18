import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
                  setState(() => _notificationsEnabled = val);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

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
              ListTile(
                leading: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red,
                ),
                title: const Text(
                  'حذف الحساب نهائياً',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => _showDeleteAccountDialog(context),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        title: Row(
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: Colors.red.shade400,
                            ),
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
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 16,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: Text(
                              'common.cancel'.tr(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
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
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
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

  void _showDeleteAccountDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false, // لمنع إغلاق النافذة بالنقر خارجها
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
              const SizedBox(width: 8),
              Text('حذف الحساب', style: TextStyle(color: Colors.red.shade700)),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'سيتم مسح بياناتك نهائياً. يرجى إدخال كلمة المرور لتأكيد هويتك وإتمام الحذف.',
                  style: TextStyle(height: 1.5),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true, // إخفاء كلمة المرور
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('تراجع', style: TextStyle(color: Colors.grey)),
            ),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            // إرسال كلمة المرور للـ Provider
                            final success = await authProvider.deleteAccount(
                              passwordController.text.trim(),
                            );

                            if (context.mounted) {
                              if (success) {
                                Navigator.pop(dialogContext);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم حذف الحساب نهائياً.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                // سيعرض هنا "كلمة المرور غير صحيحة" إذا أخطأ المستخدم
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      authProvider.errorMessage ?? 'حدث خطأ',
                                    ),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          }
                        },
                  child: authProvider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('تأكيد الحذف'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
