import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/person_entity.dart';

class EditPersonDialog extends StatefulWidget {
  final PersonEntity currentPerson;
  final ThemeData theme;
  final void Function(String name, int age) onSave;

  const EditPersonDialog({
    super.key,
    required this.currentPerson,
    required this.theme,
    required this.onSave,
  });

  @override
  State<EditPersonDialog> createState() => _EditPersonDialogState();
}

class _EditPersonDialogState extends State<EditPersonDialog> {
  late final TextEditingController nameController;
  late final TextEditingController ageController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentPerson.name);
    ageController = TextEditingController(text: widget.currentPerson.age.toString());
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.theme.cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Icon(Icons.edit_document, color: widget.theme.colorScheme.secondary),
          const SizedBox(width: 12),
          Text(
            'common.edit_data'.tr(),
            style: widget.theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.theme.colorScheme.primary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            style: TextStyle(color: widget.theme.colorScheme.primary),
            decoration: InputDecoration(
              labelText: 'common.name'.tr(),
              labelStyle: TextStyle(color: Colors.grey.shade600),
              prefixIcon: Icon(Icons.person_outline, color: widget.theme.colorScheme.secondary),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: widget.theme.colorScheme.primary, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: widget.theme.colorScheme.primary),
            decoration: InputDecoration(
              labelText: 'guests.age'.tr(),
              labelStyle: TextStyle(color: Colors.grey.shade600),
              prefixIcon: Icon(Icons.calendar_today_outlined, color: widget.theme.colorScheme.secondary),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: widget.theme.colorScheme.primary, width: 2),
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
          onPressed: () => Navigator.pop(context),
          child: Text(
            'common.cancel'.tr(),
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.theme.colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final newName = nameController.text.trim();
            final newAge = int.tryParse(ageController.text.trim());

            if (newName.isNotEmpty && newAge != null) {
              widget.onSave(newName, newAge);
              Navigator.pop(context); 
            } else {
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
  }
}
