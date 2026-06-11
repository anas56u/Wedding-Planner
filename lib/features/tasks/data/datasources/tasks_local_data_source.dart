import 'package:injectable/injectable.dart';
import '../models/task_model.dart';

abstract class ITasksLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> addTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<void> toggleTaskCompletion(String id);
}

@LazySingleton(as: ITasksLocalDataSource)
class TasksLocalDataSourceImpl implements ITasksLocalDataSource {
  final List<TaskModel> _tasks = [];

  @override
  Future<List<TaskModel>> getTasks() async {
    return _tasks;
  }

  @override
  Future<TaskModel> addTask(TaskModel task) async {
    _tasks.add(task);
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks.removeAt(index);
    } else {
      throw Exception('المهمة غير موجودة!'); 
    }
  }

  @override
  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final currentTask = _tasks[index];
      _tasks[index] = TaskModel.fromEntity(currentTask.copyWith(isCompleted: !currentTask.isCompleted));
    } else {
      throw Exception('المهمة غير موجودة!');
    }
  }
}