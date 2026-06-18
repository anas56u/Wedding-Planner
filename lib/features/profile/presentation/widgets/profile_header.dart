import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final ThemeData theme;

  const ProfileHeader({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
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
