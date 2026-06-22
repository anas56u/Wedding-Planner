import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:provider_test/features/people_management/presentation/providers/people_provider.dart';
import 'package:provider_test/features/tasks/data/models/task_model.dart';
@injectable 
class TasksProvider extends ChangeNotifier {
  final List<TaskModel> _tasks = [];
  PeopleProvider? _peopleProvider;

  List<TaskModel> get tasks => _tasks;
  void updatePeopleProvider(PeopleProvider peopleProvider) {
    _peopleProvider = peopleProvider;
  }
  void addTask(String title, {List<int>? assignedPeopleIds, List<String>? assignedPeopleNames}) {
    if (title.trim().isEmpty) return; 

    final newTask = TaskModel(
      id: DateTime.now().toString(),
      title: title,
      assignedPeopleIds: assignedPeopleIds ?? [],
      assignedPeopleNames: assignedPeopleNames ?? [],
    );
    _tasks.add(newTask);
    if (assignedPeopleIds != null && assignedPeopleIds.isNotEmpty && _peopleProvider != null) {
      for (int personId in assignedPeopleIds) {
        _peopleProvider!.toggleSelection(personId);
      }
    }

    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final currentTask = _tasks[index];
      _tasks[index] = TaskModel.fromEntity(
        currentTask.copyWith(isCompleted: !currentTask.isCompleted)
      );
      notifyListeners();
    }
  }
}