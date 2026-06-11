import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/hospitality_staff_details_screen.dart';
import '../providers/hospitality_staff_provider.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'hospitality.title'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink.shade100,
        foregroundColor: Colors.black87,
      ),
      body: Consumer<HospitalityStaffProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.pink));
          }

          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          if (provider.staffList.isEmpty) {
            return Center(
                child: Text(
                  'hospitality.no_data'.tr(),
                  style: const TextStyle(fontSize: 18),
                ));
          }

          return ListView.builder(
            padding: const EdgeInsetsDirectional.all(12),
            itemCount: provider.staffList.length,
            itemBuilder: (context, index) {
              final staffMember = provider.staffList[index];
              return ListTile(
                title: Text('${staffMember.firstName} ${staffMember.lastName}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HospitalityStaffDetailsScreen(staff: staffMember),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
