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

    // استدعاء البيانات بعد بناء الشاشة (ممارسة صحيحة 100%)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HospitalityStaffProvider>();

      if (provider.staffList.isEmpty) {
        provider.fetchStaff();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // جلب الـ Theme الموحد لضمان تناسق الألوان
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('hospitality.title'.tr()),
        // أزلنا الألوان الثابتة (Pink) لنعتمد على إعدادات الـ AppBar في app_theme.dart
      ),
      body: Consumer<HospitalityStaffProvider>(
        builder: (context, provider, child) {
          // 1. حالة التحميل (Loading State)
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.secondary, // استخدام اللون الذهبي من الـ Theme
              ),
            );
          }

          // 2. حالة الخطأ (Error State)
          if (provider.errorMessage != null) {
            return HospitalityErrorState(theme: theme, errorMessage: provider.errorMessage!);
          }

          // 3. حالة عدم وجود بيانات (Empty State)
          if (provider.staffList.isEmpty) {
            return HospitalityEmptyState(theme: theme);
          }

          // 4. حالة عرض البيانات (Success State)
          // استخدمنا ListView.separated بدلاً من builder لإضافة مسافات أنيقة بين البطاقات
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