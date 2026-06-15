import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/person_entity.dart';
import '../pages/person_details_screen.dart';

class PersonCard extends StatelessWidget {
  final PersonEntity person;
  final bool isCompletedTab;
  final ThemeData theme;
  final VoidCallback onToggleAttendance;
  final VoidCallback onAddTask;

  const PersonCard({
    super.key,
    required this.person,
    required this.isCompletedTab,
    required this.theme,
    required this.onToggleAttendance,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('person_${person.id}'),
      direction: DismissDirection.startToEnd,
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.secondary, theme.colorScheme.secondary.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsetsDirectional.only(start: 24),
        child: Row(
          children: [
            const Icon(Icons.add_task_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              'guests.reminder_task'.tr(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        onAddTask();
        return false;
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          clipBehavior: Clip.hardEdge,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PersonDetailsScreen(initialPerson: person)),
              );
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: isCompletedTab ? Colors.green.shade50 : theme.colorScheme.primary.withOpacity(0.05),
              child: Icon(
                isCompletedTab ? Icons.check_rounded : Icons.person_outline_rounded,
                color: isCompletedTab ? Colors.green.shade600 : theme.colorScheme.primary,
              ),
            ),
            title: Text(
              person.name,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
            subtitle: Text(
              '${'guests.age'.tr()}: ${person.age}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            trailing: isCompletedTab
                ? OutlinedButton.icon(
                    onPressed: onToggleAttendance,
                    icon: Icon(Icons.undo_rounded, size: 18, color: Colors.red.shade400),
                    label: Text('guests.undo_attended'.tr(), style: TextStyle(color: Colors.red.shade400)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: onToggleAttendance,
                    icon: const Icon(Icons.how_to_reg_rounded, size: 18),
                    label: Text('guests.mark_attended'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
