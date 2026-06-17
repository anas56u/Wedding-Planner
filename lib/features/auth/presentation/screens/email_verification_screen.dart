import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
// 🌟 استورد شاشة الـ Dashboard الخاصة بك هنا
import '../../../dashboard/presentation/pages/dashboard_screen.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد الحساب'),
        centerTitle: true,
      ),
      // نستخدم Consumer لكي نجعل الزر يظهر مؤشر تحميل (Loading) أثناء مخاطبة فايربيس
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.mark_email_unread_rounded, size: 80, color: Colors.blue),
                const SizedBox(height: 24),
                const Text(
                  'لقد أرسلنا رابط التأكيد إلى بريدك الإلكتروني.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'يرجى فتح الإيميل والضغط على الرابط، ثم العودة والضغط على الزر أدناه.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                
                // 🌟 الزر اليدوي (Manual Trigger)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: authProvider.isLoading ? null : () async {
                    
                    // 1. استدعاء الدالة من الـ Provider
                    final isVerified = await authProvider.checkEmailVerification();

                    // 2. إذا رجعت true (يعني فايربيس أكد أنه ضغط الرابط)
                    if (isVerified) {
                      if (context.mounted) {
                        // نمسح هذه الشاشة وننقله للرئيسية
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (_) => const DashboardScreen())
                        );
                      }
                    } else {
                      // 3. المسار غير السعيد: لم يضغط على الرابط!
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('لم يتم التأكيد بعد. تحقق من صندوق الوارد أو البريد المزعج (Spam).'),
                            backgroundColor: Colors.red.shade400,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: authProvider.isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('نعم، لقد وثقت حسابي', style: TextStyle(fontSize: 18)),
                ),

                const SizedBox(height: 16),

                // 🌟 زر إعادة الإرسال (Best Practice للـ UX)
                TextButton(
                  onPressed: authProvider.isLoading ? null : () async {
                    final sent = await authProvider.resendEmailVerification();
                    if (sent && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم إعادة إرسال الرابط بنجاح!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('لم يصلك الرابط؟ إعادة إرسال', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}