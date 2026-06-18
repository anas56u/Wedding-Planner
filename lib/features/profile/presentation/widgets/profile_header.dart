import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/features/auth/presentation/providers/auth_provider.dart';
import 'edit_profile_dialog.dart'; // تأكد من المسار الصحيح

class ProfileHeader extends StatelessWidget {
  final ThemeData theme;

  const ProfileHeader({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    // لماذا نستخدم context.watch ؟
    // watch تجعل هذه الـ Widget تستمع لأي تغيير يحدث في AuthProvider.
    // بمجرد أن تنجح عملية الحفظ وتتغير قيمة _currentUser، سيتم إعادة رسم هذا الجزء فقط 
    // ليظهر الاسم الجديد فوراً دون الحاجة لعمل تحديث للصفحة.
    final currentUser = context.watch<AuthProvider>().currentUser;

    // استخراج البيانات الحالية (مع وضع قيم احتياطية في حال كانت null)
    final String displayName = currentUser?.name?.isNotEmpty == true 
        ? currentUser!.name! 
        : 'مستخدم جديد';
    
    final String displayAge = currentUser?.age != null && currentUser!.age! > 0 
        ? '${currentUser.age} سنة' 
        : 'العمر غير محدد';

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.secondary, width: 2),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(Icons.person_outline, size: 40, color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 16),
            // عرض اسم المستخدم الحقيقي
            Text(
              'settings.welcome'.tr(args: [displayName]), // يمكنك تعديل الترجمة لتستقبل الاسم
              // أو استخدام نص مباشر: 'مرحباً، $displayName'
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            // عرض عمر المستخدم بدلاً من subtitle ثابت
            Text(
              displayAge,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
        
        // زر تعديل البروفايل (أيقونة قلم بجانب النص أو فوقه)
        Positioned(
          top: 0,
          right: 0, // لضبط مكان الزر في زاوية الهيدر
          child: IconButton(
            icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
            onPressed: () {
              // فتح نافذة التعديل المنبثقة
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
}