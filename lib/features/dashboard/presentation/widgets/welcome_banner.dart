import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'countdown_badge.dart';

class WelcomeBanner extends StatelessWidget {
  final String dailyTip;
  final ThemeData theme;

  const WelcomeBanner({
    super.key,
    required this.dailyTip,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'dashboard.wedding_approaching'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              const CountdownBadge(),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
