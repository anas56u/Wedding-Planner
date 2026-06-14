import 'package:flutter/material.dart';

class SettingsCard extends StatelessWidget {
  final ThemeData theme;
  final List<Widget> children;

  const SettingsCard({
    super.key,
    required this.theme,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.hardEdge, 
        child: Column(
          children: children,
        ),
      ),
    );
  }
}
