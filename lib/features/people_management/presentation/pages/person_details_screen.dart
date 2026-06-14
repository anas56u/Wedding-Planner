import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// 🌟 استخدام الكيان النقي
import '../../domain/entities/person_entity.dart';
import '../providers/people_provider.dart'; 

class PersonDetailsScreen extends StatelessWidget {
  final PersonEntity initialPerson;

  const PersonDetailsScreen({super.key, required this.initialPerson});

  @override
  Widget build(BuildContext context) {
    // جلب الثيم لتوحيد الألوان
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'guests.details'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // تم إزالة زر التعديل من هنا لنقله إلى الأسفل (UX Best Practice)
      ),
      body: Consumer<PeopleProvider>(
        builder: (context, provider, child) {
          // التحديث الفوري للبيانات
          final person = provider.allPeople.firstWhere(
            (p) => p.id == initialPerson.id,
            orElse: () => initialPerson, 
          );

          // تحديد الألوان بناءً على حالة الحضور
          final statusColor = person.isSelected ? Colors.green.shade600 : theme.colorScheme.primary;
          final statusBgColor = person.isSelected ? Colors.green.shade50 : theme.colorScheme.primary.withOpacity(0.05);
          final statusIcon = person.isSelected ? Icons.how_to_reg_rounded : Icons.person_outline_rounded;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. الصورة الرمزية (Avatar) بتصميم حديث
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusBgColor,
                    border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: statusBgColor,
                    child: Icon(
                      statusIcon,
                      size: 50,
                      color: statusColor,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 2. بطاقة المعلومات (Info Card)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
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
                    children: [
                      _buildInfoRow('guests.id_number'.tr(), '#${person.id}', theme),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                      
                      _buildInfoRow('common.name'.tr(), person.name, theme),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                      
                      _buildInfoRow('guests.age'.tr(), '${person.age} ${'common.year'.tr()}', theme),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                      
                      // صف الحالة مع لون مميز
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'guests.status'.tr(),
                            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              person.isSelected ? 'guests.completed'.tr() : 'guests.pending'.tr(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 3. زر التعديل الرئيسي (Primary Action Button)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditDialog(context, person, theme),
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    label: Text(
                      'common.edit_data'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // دالة بناء صفوف المعلومات
  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  // 🌟 نافذة التعديل بتصميم موحد وعصري
  void _showEditDialog(BuildContext context, PersonEntity currentPerson, ThemeData theme) {
    final nameController = TextEditingController(text: currentPerson.name);
    final ageController = TextEditingController(text: currentPerson.age.toString());

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.cardTheme.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(Icons.edit_document, color: theme.colorScheme.secondary),
              const SizedBox(width: 12),
              Text(
                'common.edit_data'.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // حقل الاسم
              TextField(
                controller: nameController,
                style: TextStyle(color: theme.colorScheme.primary),
                decoration: InputDecoration(
                  labelText: 'common.name'.tr(),
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(Icons.person_outline, color: theme.colorScheme.secondary),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // حقل العمر
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: theme.colorScheme.primary),
                decoration: InputDecoration(
                  labelText: 'guests.age'.tr(),
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(Icons.calendar_today_outlined, color: theme.colorScheme.secondary),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
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
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final newName = nameController.text.trim();
                final newAge = int.tryParse(ageController.text.trim());

                if (newName.isNotEmpty && newAge != null) {
                  context.read<PeopleProvider>().editPerson(currentPerson.id, newName, newAge);
                  Navigator.pop(dialogContext); 
                } else {
                  // رسالة خطأ عند إدخال بيانات غير صحيحة
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 12),
                          const Expanded(child: Text('الرجاء إدخال اسم وعمر صحيحين.')),
                        ],
                      ),
                      backgroundColor: Colors.red.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
              child: Text('common.save_changes'.tr()),
            ),
          ],
        );
      },
    );
  }
}