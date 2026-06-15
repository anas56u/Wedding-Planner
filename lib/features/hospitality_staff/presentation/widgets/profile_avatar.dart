import 'package:flutter/material.dart';
import 'package:provider_test/features/hospitality_staff/data/models/hospitality_staff_model.dart';

class ProfileAvatar extends StatelessWidget {
  final HospitalityStaffModel currentStaff;
  final ThemeData theme;

  const ProfileAvatar({
    super.key,
    required this.currentStaff,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final initial = currentStaff.firstName.isNotEmpty 
        ? currentStaff.firstName[0].toUpperCase() 
        : '?';

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.secondary, width: 3),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          currentStaff.imageUrl,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 120,
              height: 120,
              color: theme.colorScheme.primary.withOpacity(0.05),
              child: Center(
                child: Text(
                  initial,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
