import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../dashboard/presentation/pages/dashboard_screen.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('auth.verify_title'.tr()),
        centerTitle: true,
      ),
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
                Text(
                  'auth.verify_sent_message'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'auth.verify_instruction'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: authProvider.isLoading ? null : () async {
                    final isVerified = await authProvider.checkEmailVerification();
                    if (isVerified) {
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (_) => const DashboardScreen())
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('auth.verify_not_verified'.tr()),
                            backgroundColor: Colors.red.shade400,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: authProvider.isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('auth.verify_confirmed_button'.tr(), style: const TextStyle(fontSize: 18)),
                ),

                const SizedBox(height: 16),
                TextButton(
                  onPressed: authProvider.isLoading ? null : () async {
                    final sent = await authProvider.resendEmailVerification();
                    if (sent && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('auth.verify_resend_success'.tr()),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: Text('auth.verify_resend_link'.tr(), style: const TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}