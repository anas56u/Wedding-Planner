import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/features/auth/presentation/providers/auth_provider.dart';

class EditProfileDialog extends StatefulWidget {
  final ThemeData theme;
  
  const EditProfileDialog({super.key, required this.theme});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    // كيف يعمل؟ نقوم بجلب بيانات المستخدم الحالية من الـ Provider
    // ونضعها كقيمة مبدئية داخل حقول الإدخال لتسهيل التعديل على المستخدم
    final currentUser = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: currentUser?.name ?? '');
    _ageController = TextEditingController(text: currentUser?.age?.toString() ?? '');
  }

  @override
  void dispose() {
    // أفضل الممارسات: تنظيف الذاكرة (Memory Management) عند إغلاق النافذة
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    // التحقق من صحة المدخلات (Validation)
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      
      final newName = _nameController.text.trim();
      final newAge = int.parse(_ageController.text.trim());

      // استدعاء دالة التحديث التي أنشأناها في الـ Provider
      final success = await authProvider.updateUserProfile(newName, newAge);

      if (mounted) {
        if (success) {
          Navigator.pop(context); // إغلاق النافذة عند النجاح
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث البيانات بنجاح!'), backgroundColor: Colors.green),
          );
        } else {
          // عرض رسالة الخطأ القادمة من الـ Provider
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.errorMessage ?? 'حدث خطأ'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // نستخدم Consumer لمراقبة حالة الـ isLoading وإظهار مؤشر التحميل في الزر
    return AlertDialog(
      backgroundColor: widget.theme.cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        'تعديل الملف الشخصي',
        style: widget.theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: widget.theme.colorScheme.primary,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // لكي لا تأخذ النافذة مساحة الشاشة كاملة
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'الاسم',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال الاسم';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'العمر',
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال العمر';
                }
                if (int.tryParse(value) == null) {
                  return 'يرجى إدخال رقم صحيح';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
        ),
        Consumer<AuthProvider>(
          builder: (context, provider, child) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: provider.isLoading ? null : _submitUpdate,
              child: provider.isLoading
                  ? const SizedBox(
                      width: 20, height: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text('حفظ'),
            );
          },
        ),
      ],
    );
  }
}