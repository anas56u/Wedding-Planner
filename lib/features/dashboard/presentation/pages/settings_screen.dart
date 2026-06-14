import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../widgets/profile_header.dart';
import '../widgets/section_title.dart';
import '../widgets/settings_card.dart';
import '../widgets/language_dropdown.dart';
import '../widgets/switch_option.dart';
import '../widgets/action_option.dart';
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
                  // سلوك شكلي مستقبلي
                },
              ),
              SettingsDivider(theme: theme),
              ActionOption(
                theme: theme,
                title: 'settings.logout'.tr(),
                icon: Icons.logout_rounded,
                isDestructive: true,
                onTap: () {
                  // سلوك شكلي مستقبلي
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

}