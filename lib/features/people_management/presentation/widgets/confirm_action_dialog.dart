import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/person_entity.dart';

class ConfirmActionDialog extends StatelessWidget {
  final PersonEntity person;
  final bool isCompletedTab;
  final ThemeData theme;

  const ConfirmActionDialog({
    super.key,
    required this.person,
    required this.isCompletedTab,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final String actionText = isCompletedTab ? 'guests.undo_attended'.tr() : 'guests.mark_attended'.tr();
    return AlertDialog(
      backgroundColor: theme.cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        'guests.confirm_action'.tr(),
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
      ),
      content: Text(
        'guests.confirm_message'.tr(namedArgs: {'action': actionText, 'name': person.name}),
        style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('common.cancel'.tr(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isCompletedTab ? Colors.red.shade400 : Colors.green.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('common.confirm'.tr()),
        ),
      ],
    );
  }
}
