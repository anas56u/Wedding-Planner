import 'package:flutter/material.dart';

class SettingsDivider extends StatelessWidget {
  final ThemeData theme;

  const SettingsDivider({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: theme.colorScheme.primary.withOpacity(0.05),
      indent: 60,
      endIndent: 16,
    );
  }
}
