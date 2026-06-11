import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/features/hospitality_staff/data/models/hospitality_staff_model.dart';
import '../providers/hospitality_staff_provider.dart';

class HospitalityStaffDetailsScreen extends StatelessWidget {
  final HospitalityStaffModel staff;

  const HospitalityStaffDetailsScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'hospitality.details'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink.shade100,
      ),
      body: Consumer<HospitalityStaffProvider>(
        builder: (context, provider, child) {
          final currentStaff = provider.staffList.firstWhere(
            (s) => s.id == staff.id,
            orElse: () => staff,
          );

          return Padding(
            padding: const EdgeInsetsDirectional.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(currentStaff.imageUrl),
                ),
                const SizedBox(height: 20),
                Text(
                  '${currentStaff.firstName} ${currentStaff.lastName}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'hospitality.age'.tr(namedArgs: {'age': currentStaff.age.toString()}),
                  style: const TextStyle(fontSize: 18),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showEditDialog(context, currentStaff),
                    child: Text('common.edit_data'.tr()),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, HospitalityStaffModel currentStaff) {
    final firstNameController = TextEditingController(
      text: currentStaff.firstName,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'hospitality.edit_name'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: firstNameController,
            decoration: InputDecoration(
              labelText: 'hospitality.first_name'.tr(),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'common.cancel'.tr(),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
              onPressed: () {
                final newName = firstNameController.text.trim();
                if (newName.isNotEmpty) {
                  final updatedStaff =
                      currentStaff.copyWith(firstName: newName);

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
