import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider_test/features/people_management/domain/entities/person_entity.dart';

class AddTaskDialog extends StatefulWidget {
  final ThemeData theme;
  final List<PersonEntity> allPeople;
  final void Function(String title, List<int> assignedPeopleIds, List<String> assignedPeopleNames) onAdd;

  const AddTaskDialog({
    super.key,
    required this.theme,
    required this.allPeople,
    required this.onAdd,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  late final TextEditingController controller;
  final List<PersonEntity> selectedPeople = [];

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.theme.cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Icon(Icons.add_task_rounded, color: widget.theme.colorScheme.secondary),
          const SizedBox(width: 12),
          Text(
            'tasks.add_new'.tr(),
            style: widget.theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.theme.colorScheme.primary,
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
              TextField(
                controller: controller,
                autofocus: true,
                style: TextStyle(color: widget.theme.colorScheme.primary),
                decoration: InputDecoration(
                  hintText: 'tasks.example'.tr(),
                  hintStyle: TextStyle(color: Colors.grey.shade400),
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
              const SizedBox(height: 24),
              
              Text(
                'tasks.assign_to'.tr(),
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),

              if (widget.allPeople.isNotEmpty)
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: widget.allPeople.map((person) {
                    final isSelected = selectedPeople.contains(person);
                    
                    return FilterChip(
                      label: Text(person.name),
                      labelStyle: TextStyle(
                        color: isSelected ? widget.theme.colorScheme.primary : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      selected: isSelected,
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: widget.theme.colorScheme.secondary.withOpacity(0.2),
                      checkmarkColor: widget.theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? widget.theme.colorScheme.secondary : Colors.grey.shade300,
                        ),
                      ),
                      onSelected: (bool selected) {
                        setState(() {
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              final selectedIds = selectedPeople.map((p) => p.id).toList();
              final selectedNames = selectedPeople.map((p) => p.name).toList();

              widget.onAdd(controller.text.trim(), selectedIds, selectedNames);
              Navigator.pop(context);
            }
          },
          child: Text('common.add'.tr()),
        ),
      ],
    );
  }
}
