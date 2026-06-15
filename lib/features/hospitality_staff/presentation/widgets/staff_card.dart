import 'package:flutter/material.dart';
import 'package:provider_test/features/hospitality_staff/data/models/hospitality_staff_model.dart';
import 'package:provider_test/features/hospitality_staff/presentation/pages/hospitality_staff_details_screen.dart';

class StaffCard extends StatelessWidget {
  final HospitalityStaffModel staffMember;
  final ThemeData theme;

  const StaffCard({
    super.key,
    required this.staffMember,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final String initial = staffMember.firstName.isNotEmpty 
        ? staffMember.firstName[0].toUpperCase() 
        : '?';

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HospitalityStaffDetailsScreen(staff: staffMember),
              ),
            );
          },
          splashColor: theme.colorScheme.secondary.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    initial,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${staffMember.firstName} ${staffMember.lastName}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'عضو فريق الضيافة',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
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
