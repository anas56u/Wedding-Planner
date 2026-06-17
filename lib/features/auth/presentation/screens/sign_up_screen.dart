import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/features/auth/presentation/screens/email_verification_screen.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // 🌟 حقل التأكيد

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success) {
        if (mounted) {
          // 🌟 التعديل هنا: قمنا بحذف الـ showDialog القديم
          // ووضعنا كود التوجيه إلى شاشة التحقق الجديدة
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EmailVerificationScreen()),
          );
        }
      } else {
        if (mounted && authProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage!),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // زر الرجوع يأخذ لون الكحلي الأساسي
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 80,
                    color: theme.colorScheme.secondary, // الذهبي/روز جولد
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'إنشاء حساب جديد',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ابدأ رحلة التخطيط لزفافك بكل سهولة',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- 1. حقل البريد الإلكتروني ---
                  _buildTextField(
                    controller: _emailController,
                    label: 'البريد الإلكتروني',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'يرجى إدخال البريد الإلكتروني';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'صيغة البريد الإلكتروني غير صحيحة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- 2. حقل كلمة المرور ---
                  _buildTextField(
                    controller: _passwordController,
                    label: 'كلمة المرور',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'يرجى إدخال كلمة المرور';
                      if (value.length < 6) return 'يجب أن لا تقل عن 6 أحرف';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- 3. حقل تأكيد كلمة المرور ---
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'تأكيد كلمة المرور',
                    icon: Icons.lock_reset_rounded,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'يرجى تأكيد كلمة المرور';
                      // 🌟 التحقق من التطابق هندسياً
                      if (value != _passwordController.text) return 'كلمتا المرور غير متطابقتين';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // --- 4. زر إنشاء الحساب ---
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleSignUp,
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('إنشاء الحساب'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- 5. زر العودة لتسجيل الدخول ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('لديك حساب بالفعل؟', style: theme.textTheme.bodyMedium),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // نفس دالة بناء الحقول المساعدة التي استخدمناها في شاشة تسجيل الدخول
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
      ),
    );
  }
}