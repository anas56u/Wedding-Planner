import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/features/auth/presentation/pages/email_verification_screen.dart';
import 'package:provider_test/features/auth/presentation/pages/sign_up_screen.dart';
import '../providers/auth_provider.dart';
import '../../../dashboard/presentation/pages/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  bool _rememberMe = false;
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showResetPasswordDialog(BuildContext context) {
    final TextEditingController resetEmailController = TextEditingController();

    resetEmailController.text = _emailController.text;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'auth.login_reset_title'.tr(),
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('auth.login_reset_body'.tr()),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'auth.email_label'.tr(),
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'common.cancel'.tr(),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (email.isEmpty || !email.contains('@')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('auth.login_reset_invalid_email'.tr()),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                final authProvider = context.read<AuthProvider>();
                final success = await authProvider.resetPassword(email);

                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('auth.login_reset_success'.tr()),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          authProvider.errorMessage ??
                              'common.error_occurred'.tr(),
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
              child: Text('auth.login_reset_send'.tr()),
            ),
          ],
        );
      },
    );
  }

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
          final isVerified = authProvider.currentUser?.isEmailVerified ?? false;

          if (isVerified) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const EmailVerificationScreen(),
              ),
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
                  Icon(
                    Icons.favorite_rounded,
                    size: 80,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'auth.login_title'.tr(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'auth.login_subtitle'.tr(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildTextField(
                    controller: _emailController,
                    label: 'auth.email_label'.tr(),
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'auth.email_required'.tr();
                      }

                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'auth.email_invalid'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _passwordController,
                    label: 'auth.password_label'.tr(),
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
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
                        return 'auth.password_required'.tr();
                      }
                      if (value.length < 6) {
                        return 'auth.login_password_min_length'.tr();
                      }
                      return null;
                    },
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              activeColor: theme.colorScheme.primary,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'auth.login_remember_me'.tr(),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),

                      TextButton(
                        onPressed: () {
                          _showResetPasswordDialog(context);
                        },
                        child: Text(
                          'auth.login_forgot_password'.tr(),
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
                    height: 56,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('auth.login_button'.tr()),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'auth.login_no_account'.tr(),
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'auth.login_create_account'.tr(),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
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
