import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/features/auth/presentation/providers/auth_provider.dart';
import 'edit_profile_dialog.dart';

class ProfileHeader extends StatelessWidget {
  final ThemeData theme;

  const ProfileHeader({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {

    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;


    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }


    return Stack(
      alignment: Alignment.center,
      children: [

        Column(
          children: [

            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            

            Text(
              user.name.isNotEmpty ? user.name : 'settings.default_user_name'.tr(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProfileTag(
                  icon: Icons.cake_outlined,
                  label: 'settings.user_age_years'.tr(namedArgs: {'age': user.age.toString()}),
                  color: theme.colorScheme.secondary.withOpacity(0.2),
                  textColor: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                _buildProfileTag(
                  icon: user.isEmailVerified ? Icons.verified_user_rounded : Icons.info_outline,
                  label: user.isEmailVerified ? 'settings.account_verified'.tr() : 'settings.account_unverified'.tr(),
                  color: user.isEmailVerified ? Colors.green.shade50 : Colors.orange.shade50,
                  textColor: user.isEmailVerified ? Colors.green.shade700 : Colors.orange.shade700,
                ),
              ],
            ),
          ],
        ),


        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
            tooltip: 'settings.edit_profile_tooltip'.tr(),
            onPressed: () {

              showDialog(
                context: context,
                builder: (context) => EditProfileDialog(theme: theme),
              );
            },
          ),
        ),
      ],
    );
  }


  Widget _buildProfileTag({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}