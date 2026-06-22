import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/features/people_management/domain/entities/person_entity.dart';
import 'package:provider_test/features/people_management/presentation/providers/people_provider.dart';
import '../providers/tasks_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/tasks_empty_state.dart';
import '../widgets/add_task_dialog.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('tasks.title'.tr()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.colorScheme.secondary,
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
          if (tasks.isEmpty) {
            return TasksEmptyState(theme: theme);
          }
          return ListView.separated(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
            itemCount: tasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                theme: theme,
                onToggleCompletion: (bool? value) {
                  context.read<TasksProvider>().toggleTaskCompletion(task.id);
                },
                onDelete: () {
                  context.read<TasksProvider>().deleteTask(task.id);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, ThemeData theme) {
    final allPeople = context.read<PeopleProvider>().allPeople;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AddTaskDialog(
          theme: theme,
          allPeople: allPeople,
          onAdd: (title, assignedPeopleIds, assignedPeopleNames) {
            context.read<TasksProvider>().addTask(
              title,
              assignedPeopleIds: assignedPeopleIds,
              assignedPeopleNames: assignedPeopleNames,
            );
          },
        );
      },
    );
  }
}