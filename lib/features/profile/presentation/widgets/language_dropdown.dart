import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/core/providers/language_provider.dart';
import 'package:provider_test/features/dashboard/presentation/widgets/icon_background.dart';

class LanguageDropdown extends StatelessWidget {
  final ThemeData theme;
  final String currentLocale;
  final ValueChanged<String?> onChanged;

  const LanguageDropdown({
    super.key,
    required this.theme,
    required this.currentLocale,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconBackground(icon: Icons.language, color: theme.colorScheme.secondary),
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
      
      Provider.of<LanguageProvider>(context, listen: false)
          .changeLanguage(Locale(newValue));

      await context.setLocale(Locale(newValue));
      
    }
  },
        ),
      ),
    );
  }
}
