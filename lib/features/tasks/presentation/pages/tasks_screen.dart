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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          'tasks.title'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          _showAddTaskDialog(context);
        },
      ),
      body: Consumer<TasksProvider>(
        builder: (context, provider, child) {
          final tasks = provider.tasks;

          if (tasks.isEmpty) {
            return Center(
              child: Text(
                'tasks.no_tasks'.tr(),
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsetsDirectional.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                margin: const EdgeInsetsDirectional.only(bottom: 12),
                child: ListTile(
                  leading: Checkbox(
                    value: task.isCompleted,
                    activeColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (bool? value) {
                      context.read<TasksProvider>().toggleTaskCompletion(task.id);
                    },
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? Colors.grey : Colors.black87,
                    ),
                  ),
                  subtitle: task.assignedPeopleNames.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsetsDirectional.only(top: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            textDirection: TextDirection.ltr,
                            children: [
                              const Icon(Icons.people, size: 16, color: Colors.blue),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'tasks.assisted_by'.tr(namedArgs: {'names': task.assignedPeopleNames.join('، ')}),
                                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      context.read<TasksProvider>().deleteTask(task.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

 void _showAddTaskDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    
    final allPeople = context.read<PeopleProvider>().allPeople;
    
    List<PersonEntity> selectedPeople = []; 

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'tasks.add_new'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
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
                        decoration: InputDecoration(
                          hintText: 'tasks.example'.tr(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        'tasks.assign_to'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),

                      if (allPeople.isNotEmpty)
                        Wrap(
                          spacing: 8.0, 
                          runSpacing: 4.0, 
                          children: allPeople.map((person) {
                            final isSelected = selectedPeople.contains(person);
                            
                            return FilterChip(
                              label: Text(person.name),
                              selected: isSelected,
                              selectedColor: Colors.blue.shade100,
                              checkmarkColor: Colors.blue,
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
                        Text(
                          'tasks.no_people'.tr(),
                          style: const TextStyle(color: Colors.grey),
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
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      final selectedIds = selectedPeople.map((p) => p.id).toList();
                      final selectedNames = selectedPeople.map((p) => p.name).toList();

                      context.read<TasksProvider>().addTask(
                        controller.text,
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
          }
        );
      },
    );
  }
}