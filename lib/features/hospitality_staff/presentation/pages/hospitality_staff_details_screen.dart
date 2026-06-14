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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('hospitality.details'.tr()),
        // تمت إزالة اللون الوردي الثابت ليعتمد على الـ AppTheme تلقائياً
      ),
      body: Consumer<HospitalityStaffProvider>(
        builder: (context, provider, child) {
          // جلب أحدث بيانات للموظف أو استخدام البيانات الممررة كبديل
          final currentStaff = provider.staffList.firstWhere(
            (s) => s.id == staff.id,
            orElse: () => staff,
          );

          return SingleChildScrollView( // لتجنب الـ Overflow في الشاشات الصغيرة
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. الصورة الشخصية (مع معالجة الأخطاء)
                _buildProfileAvatar(currentStaff, theme),
                
                const SizedBox(height: 24),

                // 2. بطاقة المعلومات التفصيلية
                _buildInfoCard(currentStaff, theme),

                const SizedBox(height: 40),

                // 3. زر تعديل البيانات
                SizedBox(
                  width: double.infinity,
                  height: 54, // ارتفاع معياري ومريح للضغط في أزرار الـ Call to Action
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
                      elevation: 0, // تصميم مسطح حديث (Flat Design)
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

  // ==========================================
  // دوال بناء الواجهة (UI Builders)
  // ==========================================

  // تصميم الصورة مع درع واقي (Fallback) ضد أخطاء الروابط
  Widget _buildProfileAvatar(HospitalityStaffModel currentStaff, ThemeData theme) {
    final initial = currentStaff.firstName.isNotEmpty 
        ? currentStaff.firstName[0].toUpperCase() 
        : '?';

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.secondary, width: 3), // إطار ذهبي
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
          // 🌟 الـ ErrorBuilder: بديل احترافي إذا فشل تحميل الصورة
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

  // بطاقة عرض المعلومات بطريقة منظمة
  Widget _buildInfoCard(HospitalityStaffModel currentStaff, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${currentStaff.firstName} ${currentStaff.lastName}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'عضو فريق الضيافة',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(),
          ),
          // تفاصيل إضافية (العمر)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.cake_outlined, color: Colors.grey.shade500, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'العمر', // أو يمكن جلبها من الترجمة
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
              Text(
                '${currentStaff.age} سنة',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // منطق واجهة التعديل (Dialog)
  // ==========================================

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