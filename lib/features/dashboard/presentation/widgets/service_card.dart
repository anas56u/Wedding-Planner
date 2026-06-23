import 'package:flutter/material.dart';

class HorizontalServiceCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final ThemeData theme;
  final Color? customColor;
  final VoidCallback onTap;

  const HorizontalServiceCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.theme,
    this.customColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor = customColor ?? theme.colorScheme.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16), // مسافة بين البطاقات
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          splashColor: cardColor.withOpacity(0.1),
          highlightColor: cardColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // 1. حاوية الأيقونة
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: cardColor),
                ),
                const SizedBox(width: 16),

                // 2. النصوص (Expanded ضروري هنا)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // 3. سهم للدلالة على إمكانية الضغط (Best Practice للـ UX)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}