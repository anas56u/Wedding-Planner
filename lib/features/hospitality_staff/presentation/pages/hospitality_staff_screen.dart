import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/hospitality_staff_details_screen.dart';
import '../providers/hospitality_staff_provider.dart';
import '../widgets/staff_card.dart';
import '../widgets/hospitality_empty_state.dart';
import '../widgets/hospitality_error_state.dart';

class HospitalityStaffScreen extends StatefulWidget {
  const HospitalityStaffScreen({super.key});

  @override
  State<HospitalityStaffScreen> createState() => _HospitalityStaffScreenState();
}

class _HospitalityStaffScreenState extends State<HospitalityStaffScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HospitalityStaffProvider>();

      if (provider.staffList.isEmpty) {
        provider.fetchStaff();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('hospitality.title'.tr()),
      ),
      body: Consumer<HospitalityStaffProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.secondary,
              ),
            );
          }
          if (provider.errorMessage != null) {
            return HospitalityErrorState(theme: theme, errorMessage: provider.errorMessage!);
          }
          if (provider.staffList.isEmpty) {
            return HospitalityEmptyState(theme: theme);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.staffList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final staffMember = provider.staffList[index];
              return StaffCard(staffMember: staffMember, theme: theme);
            },
          );
        },
      ),
    );
  }

}