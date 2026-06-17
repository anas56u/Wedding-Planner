import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:provider_test/features/auth/presentation/screens/sign_up_screen.dart';
// تأكد من صحة هذه المسارات بناءً على هيكل مشروعك
import '../providers/auth_provider.dart'; 
import '../../../dashboard/presentation/pages/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. مفتاح النموذج (Form Key) للتحقق من صحة المدخلات
  final _formKey = GlobalKey<FormState>();
  
  // 2. متحكمات النصوص (Controllers)
  final _emailController = TextEditingController();
  bool _rememberMe = false;
  final _passwordController = TextEditingController();
  
  // 3. حالة إظهار/إخفاء كلمة المرور
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
// دالة عرض نافذة استعادة كلمة المرور
  void _showResetPasswordDialog(BuildContext context) {
    final TextEditingController resetEmailController = TextEditingController();
    // نملأ الحقل تلقائياً إذا كان المستخدم قد كتب إيميله بالفعل في شاشة تسجيل الدخول
    resetEmailController.text = _emailController.text;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'استعادة كلمة المرور',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور.'),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (email.isEmpty || !email.contains('@')) {
                  // تنبيه بسيط إذا كان الإيميل غير صالح
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى إدخال بريد إلكتروني صحيح')),
                  );
                  return;
                }

                // إغلاق النافذة المنبثقة أولاً
                Navigator.pop(dialogContext);

                // استدعاء دالة الـ Provider
                final authProvider = context.read<AuthProvider>();
                final success = await authProvider.resetPassword(email);

                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إرسال رابط الاستعادة إلى بريدك بنجاح!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(authProvider.errorMessage ?? 'حدث خطأ'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
              child: const Text('إرسال الرابط'),
            ),
          ],
        );
      },
    );
  }
  // دالة تنفيذ تسجيل الدخول
 Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final authProvider = context.read<AuthProvider>();
      
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _rememberMe,
      );

      if (success) {
        if (mounted) {
          // 🌟 التعديل هنا: فحص حالة التوثيق قبل التوجيه
          final isVerified = authProvider.currentUser?.isEmailVerified ?? false;

          if (isVerified) {
            // موثق؟ أهلاً بك في الرئيسية
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const EmailVerificationScreen()),
            );
          }
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
      // لون الخلفية يأتي تلقائياً من الـ AppTheme (backgroundCream)
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 1. الهيدر (الشعار والترحيب) ---
                  Icon(
                    Icons.favorite_rounded, // أيقونة مؤقتة تناسب الزفاف
                    size: 80,
                    color: theme.colorScheme.secondary, // الذهبي (Rose Gold)
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'مرحباً بك مجدداً',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary, // الكحلي
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'قم بتسجيل الدخول لمتابعة تخطيط زفافك',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- 2. حقل البريد الإلكتروني ---
                  _buildTextField(
                    controller: _emailController,
                    label: 'البريد الإلكتروني',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال البريد الإلكتروني';
                      }
                      // Regex بسيط للتحقق من صيغة الإيميل
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'صيغة البريد الإلكتروني غير صحيحة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- 3. حقل كلمة المرور ---
                  _buildTextField(
                    controller: _passwordController,
                    label: 'كلمة المرور',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور';
                      }
                      if (value.length < 6) {
                        return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),

                  // --- 4. زر "نسيت كلمة المرور؟" ---
                 // --- 4. زر تذكرني + نسيت كلمة المرور ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // قسم "تذكرني"
                      Row(
                        children: [
                          SizedBox(
                            width: 24, // تصغير حجم الـ Checkbox الافتراضي
                            child: Checkbox(
                              value: _rememberMe,
                              activeColor: theme.colorScheme.primary, // لونه كحلي عند التفعيل
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'تذكرني',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      
                      // زر نسيت كلمة المرور الأصلي
                      TextButton(
                        onPressed: () {
                          _showResetPasswordDialog(context);
                        },
                        child: Text(
                          'هل نسيت كلمة المرور؟',
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),

                  SizedBox(
                    height: 56, // ارتفاع ثابت يعطي فخامة للزر
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('تسجيل الدخول'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- 6. زر "ليس لديك حساب؟ إنشاء حساب" ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ليس لديك حساب؟',
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpScreen()),
                          );
                          
                        },
                        child: Text(
                          'إنشاء حساب',
                          style: TextStyle(
                            color: theme.colorScheme.primary, // الكحلي
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

  // ==========================================
  // دالة مساعدة لبناء حقول النصوص (Clean UI Logic)
  // ==========================================
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
        fillColor: Colors.white, // خلفية الحقل بيضاء تبرز فوق الـ Cream
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // بدون حدود صلبة
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200), // حدود خفيفة جداً
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary, // لون الكحلي عند التحديد
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}