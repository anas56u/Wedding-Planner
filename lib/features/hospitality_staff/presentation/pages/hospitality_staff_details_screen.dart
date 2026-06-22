import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/features/hospitality_staff/data/models/hospitality_staff_model.dart';
import '../providers/hospitality_staff_provider.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/info_card.dart';

class HospitalityStaffDetailsScreen extends StatelessWidget {
  final HospitalityStaffModel staff;

  const HospitalityStaffDetailsScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('hospitality.details'.tr()),
      ),
      body: Consumer<HospitalityStaffProvider>(
        builder: (context, provider, child) {
          final currentStaff = provider.staffList.firstWhere(
            (s) => s.id == staff.id,
            orElse: () => staff,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfileAvatar(currentStaff: currentStaff, theme: theme),
                
                const SizedBox(height: 24),
                InfoCard(currentStaff: currentStaff, theme: theme),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditDialog(context, currentStaff, theme),
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    label: Text('common.edit_data'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, HospitalityStaffModel currentStaff, ThemeData theme) {
    final firstNameController = TextEditingController(text: currentStaff.firstName);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.cardTheme.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(Icons.edit_document, color: theme.colorScheme.secondary),
              const SizedBox(width: 12),
              Text(
                'hospitality.edit_name'.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: firstNameController,
            style: TextStyle(color: theme.colorScheme.primary),
            decoration: InputDecoration(
              labelText: 'hospitality.first_name'.tr(),
              labelStyle: TextStyle(color: theme.colorScheme.primary),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'common.cancel'.tr(),
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final newName = firstNameController.text.trim();
                if (newName.isNotEmpty) {
                  final updatedStaff = currentStaff.copyWith(firstName: newName);

                  context
                      .read<HospitalityStaffProvider>()
                      .updateStaffMemberLocally(updatedStaff);

                  Navigator.pop(dialogContext);
                }
              },
              child: Text('common.save'.tr()),
            ),
          ],
        );
      },
    );
  }
}