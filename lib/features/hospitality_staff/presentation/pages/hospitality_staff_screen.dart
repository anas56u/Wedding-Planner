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
            return _buildErrorState(theme, provider.errorMessage!);
          }

          // 3. حالة عدم وجود بيانات (Empty State)
          if (provider.staffList.isEmpty) {
            return _buildEmptyState(theme);
          }

          // 4. حالة عرض البيانات (Success State)
          // استخدمنا ListView.separated بدلاً من builder لإضافة مسافات أنيقة بين البطاقات
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.staffList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final staffMember = provider.staffList[index];
              return _buildStaffCard(context, staffMember, theme);
            },
          );
        },
      ),
    );
  }

  // ==========================================
  // دوال بناء الواجهة (UI Builders) للمحافظة على نظافة الكود
  // ==========================================

  // تصميم بطاقة موظف الضيافة (Modern Card Pattern)
  Widget _buildStaffCard(BuildContext context, dynamic staffMember, ThemeData theme) {
    // استخراج الحرف الأول من الاسم لعرضه في الصورة الرمزية
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
        clipBehavior: Clip.hardEdge, // لمنع خروج تأثير اللمس (Splash) عن الحواف
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
                // الصورة الرمزية (Avatar)
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
                
                // تفاصيل الموظف
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
                        'عضو فريق الضيافة', // يمكن وضع المسمى الوظيفي هنا مستقبلاً
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // سهم يدل على إمكانية الضغط (UX Best Practice)
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

  // تصميم حالة عدم وجود بيانات (Empty State)
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.room_service_outlined, // أيقونة تعبر عن الضيافة
              size: 64,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'hospitality.no_data'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم إضافة أي أعضاء لفريق الضيافة بعد.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // تصميم حالة الخطأ (Error State)
  Widget _buildErrorState(ThemeData theme, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'عذراً، حدث خطأ!',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}