import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/core/utlis/biometric_helper.dart';
// 1. استيراد أداة البصمة التي أنشأناها
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
  void initState() {
    super.initState();
    // 2. أفضل ممارسة (Best Practice): جلب حالة البصمة الحالية عند فتح الشاشة
    // نستخدم Future.microtask لضمان استدعاء الـ Provider بعد بناء الشاشة الأولي
    Future.microtask(() {
      if (mounted) {
        context.read<AuthProvider>().loadBiometricSettingsStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLocale = context.locale.languageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('settings.title'.tr()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ProfileHeader(theme: theme),
          const SizedBox(height: 32),

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
              SettingsDivider(theme: theme),
              
              // 3. إضافة خيار تفعيل البصمة مغلف بـ Consumer ليتفاعل مع التغييرات
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return SwitchOption(
                    theme: theme,
                    title: 'تفعيل الدخول بالبصمة',
                    icon: Icons.fingerprint_rounded,
                    value: authProvider.isBiometricEnabled,
                    onChanged: (val) async {
                      if (val) {
                        // إذا أراد المستخدم التفعيل، نظهر له نافذة تأكيد الباسورد
                        _showEnableBiometricDialog(context, authProvider);
                      } else {
                        // إذا أراد التعطيل، نعطله مباشرة بدون طلب باسورد (UX أفضل)
                        final success = await authProvider.toggleDisableBiometric();
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم إيقاف الدخول بالبصمة.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          SectionTitle(title: 'settings.about_section'.tr(), theme: theme),
          const SizedBox(height: 12),
          SettingsCard(
            theme: theme,
            // ... (باقي كود قسم about_section وأزرار حذف الحساب وتسجيل الخروج يبقى كما هو تماماً بدون تغيير)
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
                            Icon(Icons.logout_rounded, color: Colors.red.shade400),
                            const SizedBox(width: 12),
                            Text(
                              'تسجيل الخروج',
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.of(dialogContext).pop(true),
                            child: const Text('تأكيد الخروج'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmLogout == true && context.mounted) {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
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

  // 4. الدالة الجديدة المسؤولة عن Flow تفعيل البصمة الآمن
  void _showEnableBiometricDialog(BuildContext context, AuthProvider authProvider) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.fingerprint_rounded, color: Colors.blue),
              SizedBox(width: 8),
              Text('تأكيد الهوية'),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'لتفعيل ميزة الدخول بالبصمة، يرجى إدخال كلمة المرور الحالية للتأكد من هويتك.',
                  style: TextStyle(height: 1.5),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
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
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            // نستخدم Consumer هنا لكي يتغير الزر إلى دائرة تحميل إذا كان الـ Provider في حالة Loading
            Consumer<AuthProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            // 1. نغلق الـ Dialog أولاً
                            Navigator.pop(dialogContext);

                            final biometricHelper = BiometricHelper();
                            final isAuthenticated = await biometricHelper.authenticate();

                            if (isAuthenticated) {
                              final email = provider.currentUser?.email ?? '';
                              final password = passwordController.text.trim();
                              
                              final success = await provider.toggleEnableBiometric(email, password);

                              if (context.mounted) {
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم تفعيل البصمة بنجاح!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  // إذا كان الباسورد خطأ
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(provider.errorMessage ?? 'كلمة المرور غير صحيحة.'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            } else {
                              // إذا ألغى نافذة البصمة
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم إلغاء العملية.'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            }
                          }
                        },
                  child: provider.isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('تأكيد ومتابعة'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // دالة الحذف الخاصة بك (بدون تغيير)
  void _showDeleteAccountDialog(BuildContext context) {
    // ... (الكود الخاص بك هنا كما هو تماماً)
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'يرجى إدخال كلمة المرور';
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            final success = await authProvider.deleteAccount(passwordController.text.trim());
                            if (context.mounted) {
                              if (success) {
                                Navigator.pop(dialogContext);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (route) => false,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تم حذف الحساب نهائياً.'), backgroundColor: Colors.green),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(authProvider.errorMessage ?? 'حدث خطأ'), backgroundColor: Colors.redAccent),
                                );
                              }
                            }
                          }
                        },
                  child: authProvider.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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