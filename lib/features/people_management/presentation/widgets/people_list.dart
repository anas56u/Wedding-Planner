import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/person_entity.dart';
import 'person_card.dart';

class PeopleList extends StatelessWidget {
  final List<PersonEntity> people;
  final bool isCompletedTab;
  final bool isVisible;
  final ThemeData theme;
  final ValueChanged<bool> onToggleVisibility;
  final void Function(PersonEntity) onToggleAttendance;
  final void Function(PersonEntity) onAddTask;

  const PeopleList({
    super.key,
    required this.people,
    required this.isCompletedTab,
    required this.isVisible,
    required this.theme,
    required this.onToggleVisibility,
    required this.onToggleAttendance,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isCompletedTab
                    ? 'guests.attended_count'.tr(namedArgs: {'count': people.length.toString()})
                    : 'guests.pending_count'.tr(namedArgs: {'count': people.length.toString()}),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
              Row(
                children: [
                  Icon(isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.grey.shade500, size: 20),
                  Switch.adaptive(
                    value: isVisible,
                    activeColor: theme.colorScheme.secondary,
                    onChanged: onToggleVisibility,
                  ),
                ],
              ),
            ],
          ),
        ),

        if (!isVisible)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                    child: Icon(Icons.visibility_off_rounded, size: 60, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'guests.hidden_list'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: people.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isCompletedTab ? Icons.how_to_reg_rounded : Icons.people_outline_rounded, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          isCompletedTab ? 'guests.no_attended'.tr() : 'guests.no_pending'.tr(),
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: people.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final person = people[index];

                      return PersonCard(
                        person: person,
                        isCompletedTab: isCompletedTab,
                        theme: theme,
                        onToggleAttendance: () => onToggleAttendance(person),
                        onAddTask: () => onAddTask(person),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}
