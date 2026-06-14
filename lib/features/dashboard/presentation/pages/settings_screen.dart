import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
          _buildProfileHeader(theme),
          const SizedBox(height: 32),

          // قسم الإعدادات العامة
          _buildSectionTitle('settings.general_section'.tr(), theme), 
          const SizedBox(height: 12),
          _buildSettingsCard(
            theme: theme,
            children: [
              _buildLanguageDropdown(context, theme, currentLocale),
              _buildDivider(theme),
              _buildSwitchOption(
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
          _buildSectionTitle('settings.about_section'.tr(), theme),
          const SizedBox(height: 12),
          _buildSettingsCard(
            theme: theme,
            children: [
              _buildActionOption(
                theme: theme,
                title: 'settings.privacy_policy'.tr(),
                icon: Icons.privacy_tip_outlined,
                onTap: () {
                  // سلوك شكلي مستقبلي
                },
              ),
              _buildDivider(theme),
              _buildActionOption(
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

  // ==========================================================
  // دالة بناء العناوين تدعم الـ Expanded لتفادي أي مشاكل محاذية
  // ==========================================================
  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

 Widget _buildSettingsCard({required ThemeData theme, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        // إبقاء الظل (Shadow) فقط في الـ Container لأنه لا يتأثر بالـ Material
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // 🌟 التغيير الجوهري هنا: إضافة ويدجت Material
      child: Material(
        color: theme.cardTheme.color, // نقلنا اللون إلى هنا
        borderRadius: BorderRadius.circular(20), // نقلنا الحواف الدائرية إلى هنا
        // 💡 أفضل الممارسات: استخدام Clip.hardEdge
        // هذا يضمن أن تأثير اللمس (Splash) لا يخرج (يطفح) خارج الحواف الدائرية للبطاقة
        clipBehavior: Clip.hardEdge, 
        child: Column(
          children: children,
        ),
      ),
    );
  }
  Widget _buildLanguageDropdown(BuildContext context, ThemeData theme, String currentLocale) {
    return ListTile(
      leading: _buildIconBackground(Icons.language, theme.colorScheme.secondary, theme),
      title: Text(
        'settings.app_language'.tr(),
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentLocale,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.primary),
          borderRadius: BorderRadius.circular(16),
          items: const [
            DropdownMenuItem(value: 'ar', child: Text('العربية')),
            DropdownMenuItem(value: 'en', child: Text('English')),
          ],
          onChanged: (String? newValue) async {
            if (newValue != null && newValue != currentLocale) {
              await context.setLocale(Locale(newValue));
              setState(() {}); 
            }
          },
        ),
      ),
    );
  }

  Widget _buildSwitchOption({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: _buildIconBackground(icon, theme.colorScheme.secondary, theme),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeColor: theme.colorScheme.secondary,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionOption({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red.shade400 : theme.colorScheme.secondary;
    return ListTile(
      onTap: onTap,
      leading: _buildIconBackground(icon, color, theme),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red.shade400 : theme.colorScheme.primary,
        ),
      ),
      trailing: isDestructive 
        ? null 
        : const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 1,
      color: theme.colorScheme.primary.withOpacity(0.05),
      indent: 60,
      endIndent: 16,
    );
  }

  Widget _buildIconBackground(IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.secondary, width: 2),
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(Icons.person_outline, size: 40, color: theme.colorScheme.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'settings.welcome'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          'settings.subtitle'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}