import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/features/people_management/domain/entities/person_entity.dart';
import 'package:provider_test/features/people_management/presentation/providers/people_provider.dart';
import '../providers/tasks_provider.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('tasks.title'.tr()),
        // تم الاستغناء عن الألوان الثابتة للاعتماد على الـ AppTheme
      ),
      // تصميم حديث لزر الإضافة العائم (FAB)
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.colorScheme.secondary, // اللون الذهبي
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_task_rounded),
        label: Text(
          'common.add'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showAddTaskDialog(context, theme),
      ),
      body: Consumer<TasksProvider>(
        builder: (context, provider, child) {
          final tasks = provider.tasks;

          // 1. حالة عدم وجود مهام (Empty State)
          if (tasks.isEmpty) {
            return _buildEmptyState(theme);
          }

          // 2. حالة عرض المهام
          return ListView.separated(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80), // bottom 80 لكي لا يغطي الزر العائم على آخر مهمة
            itemCount: tasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskCard(context, task, theme);
            },
          );
        },
      ),
    );
  }

  // ==========================================
  // دوال بناء الواجهة (UI Builders)
  // ==========================================

  // تصميم بطاقة المهمة (Task Card)
  Widget _buildTaskCard(BuildContext context, dynamic task, ThemeData theme) {
    // إذا كانت المهمة منجزة، نجعلها شفافة قليلاً (Opacity) لتعزيز الإحساس بالإنجاز
    final isCompleted = task.isCompleted;
    final cardOpacity = isCompleted ? 0.6 : 1.0;

    return Opacity(
      opacity: cardOpacity,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted ? theme.colorScheme.secondary.withOpacity(0.5) : Colors.transparent,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              // مربع الاختيار (Checkbox)
              leading: Transform.scale(
                scale: 1.2, // تكبير المربع قليلاً لسهولة الضغط
                child: Checkbox(
                  value: task.isCompleted,
                  activeColor: theme.colorScheme.secondary, // ذهبي عند الإنجاز
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5), width: 1.5),
                  onChanged: (bool? value) {
                    context.read<TasksProvider>().toggleTaskCompletion(task.id);
                  },
                ),
              ),
              // عنوان المهمة
              title: Text(
                task.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted ? Colors.grey.shade600 : theme.colorScheme.primary,
                ),
              ),
              // الأشخاص الموكلين بالمهمة (إن وجدوا)
              subtitle: task.assignedPeopleNames.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.people_alt_outlined, size: 18, color: theme.colorScheme.secondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'tasks.assisted_by'.tr(namedArgs: {'names': task.assignedPeopleNames.join('، ')}),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
              // زر الحذف
              trailing: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 20),
                ),
                onPressed: () {
                  context.read<TasksProvider>().deleteTask(task.id);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // تصميم حالة عدم وجود بيانات (Empty State)
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.checklist_rounded, 
              size: 70,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'tasks.title'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'tasks.no_tasks'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // منطق واجهة إضافة مهمة (Dialog)
  // ==========================================

  void _showAddTaskDialog(BuildContext context, ThemeData theme) {
    final TextEditingController controller = TextEditingController();
    final allPeople = context.read<PeopleProvider>().allPeople;
    List<PersonEntity> selectedPeople = [];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: theme.cardTheme.color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  Icon(Icons.add_task_rounded, color: theme.colorScheme.secondary),
                  const SizedBox(width: 12),
                  Text(
                    'tasks.add_new'.tr(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // حقل إدخال اسم المهمة مع تصميم موحد
                      TextField(
                        controller: controller,
                        autofocus: true,
                        style: TextStyle(color: theme.colorScheme.primary),
                        decoration: InputDecoration(
                          hintText: 'tasks.example'.tr(),
                          hintStyle: TextStyle(color: Colors.grey.shade400),
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
                      const SizedBox(height: 24),
                      
                      Text(
                        'tasks.assign_to'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // عرض الأشخاص باستخدام FilterChip
                      if (allPeople.isNotEmpty)
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: allPeople.map((person) {
                            final isSelected = selectedPeople.contains(person);
                            
                            return FilterChip(
                              label: Text(person.name),
                              labelStyle: TextStyle(
                                color: isSelected ? theme.colorScheme.primary : Colors.grey.shade700,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              selected: isSelected,
                              // تنسيق الـ Chip حسب الـ Theme
                              backgroundColor: Colors.grey.shade100,
                              selectedColor: theme.colorScheme.secondary.withOpacity(0.2),
                              checkmarkColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected ? theme.colorScheme.secondary : Colors.grey.shade300,
                                ),
                              ),
                              onSelected: (bool selected) {
                                setDialogState(() {
                                  if (selected) {
                                    selectedPeople.add(person);
                                  } else {
                                    selectedPeople.remove(person);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange.shade400, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'tasks.no_people'.tr(),
                                style: TextStyle(color: Colors.orange.shade700),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      final selectedIds = selectedPeople.map((p) => p.id).toList();
                      final selectedNames = selectedPeople.map((p) => p.name).toList();

                      context.read<TasksProvider>().addTask(
                        controller.text.trim(),
                        assignedPeopleIds: selectedIds,
                        assignedPeopleNames: selectedNames,
                      );
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: Text('common.add'.tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }
}