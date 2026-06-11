import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // ضروري لاستخدام .tr() و context.setLocale()

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // جلب اللغة الحالية للتطبيق
    final isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        // استخدام .tr() لترجمة النص حسب اللغة الحالية
        title: Text('settings'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.language, color: Colors.blue),
                        const SizedBox(width: 12),
                        Text(
                          'app_language',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ).tr()
                      ],
                    ),
                    Row(
                      children: [
                        Text('english'.tr(), style: TextStyle(color: isArabic ? Colors.grey : Colors.blue)),
                        Switch(
                          value: isArabic,
                          activeColor: Colors.blue,
                          // يتم استدعاء هذه الدالة عند الضغط على الـ Switch
                          onChanged: (bool value) async {
                            if (value) {
                              // إذا كانت القيمة true، حوّل للعربية
                              await context.setLocale(const Locale('ar'));
                            } else {
                              // إذا كانت القيمة false، حوّل للإنجليزية
                              await context.setLocale(const Locale('en'));
                            }
                          },
                        ),
                        Text('arabic'.tr(), style: TextStyle(color: isArabic ? Colors.blue : Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}