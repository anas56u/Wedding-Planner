import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class TaskCard extends StatelessWidget {
  final dynamic task;
  final ThemeData theme;
  final ValueChanged<bool?> onToggleCompletion;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.theme,
    required this.onToggleCompletion,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
              leading: Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: task.isCompleted,
                  activeColor: theme.colorScheme.secondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5), width: 1.5),
                  onChanged: onToggleCompletion,
                ),
              ),
              title: Text(
                task.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted ? Colors.grey.shade600 : theme.colorScheme.primary,
                ),
              ),
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
              trailing: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 20),
                ),
                onPressed: onDelete,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
