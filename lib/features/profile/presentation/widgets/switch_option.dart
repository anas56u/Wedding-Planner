import 'package:flutter/material.dart';
import 'package:provider_test/features/dashboard/presentation/widgets/icon_background.dart';

class SwitchOption extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SwitchOption({
    super.key,
    required this.theme,
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconBackground(icon: icon, color: theme.colorScheme.secondary),
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
}
