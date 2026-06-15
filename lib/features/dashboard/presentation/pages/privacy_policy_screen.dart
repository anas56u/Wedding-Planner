import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('settings.privacy_policy'.tr()), // سيأخذ الترجمة الموجودة عندك
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: theme.cardTheme.color, // لون الكارد من الثيم
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'شروط الاستخدام وسياسة الخصوصية',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '''
1. مقدمة:
مرحباً بك في تطبيقنا لتخطيط الزفاف. باستخدامك لهذا التطبيق، فإنك توافق على الشروط والأحكام التالية.

2. جمع البيانات:
نحن نقوم بجمع بعض البيانات الأساسية مثل الاسم والبريد الإلكتروني لتحسين تجربتك في تخطيط زفافك ومزامنة ضيوفك.

3. حماية المعلومات:
نحن نلتزم بحماية بياناتك الشخصية ولا نقوم بمشاركتها مع أي أطراف ثالثة دون إذنك المسبق.

4. التحديثات:
نحتفظ بالحق في تعديل هذه الشروط في أي وقت. استمرارك في استخدام التطبيق يعني موافقتك على التعديلات.
                ''', // يمكنك تعديل هذا النص لاحقاً أو ربطه بـ easy_localization
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                  height: 1.8, // تباعد الأسطر لسهولة القراءة
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}