import 'package:flutter/material.dart';
import 'icon_background.dart';

class ActionOption extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const ActionOption({
    super.key,
    required this.theme,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red.shade400 : theme.colorScheme.secondary;
    return ListTile(
      onTap: onTap,
      leading: IconBackground(icon: icon, color: color),
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
}
