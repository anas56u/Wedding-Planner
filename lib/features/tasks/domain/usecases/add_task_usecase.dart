import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:provider_test/core/errors/Failure.dart';
import '../entities/task_entity.dart';
import '../repositories/tasks_repository.dart';

@lazySingleton
class AddTaskUseCase {
  final ITasksRepository repository;

  AddTaskUseCase(this.repository);

  Future<Either<Failure, TaskEntity>> execute({
    required String title,
    List<int> assignedPeopleIds = const [],
    List<String> assignedPeopleNames = const [],
  }) async {
    // 🌟 قوانين العمل (Business Logic)
    if (title.trim().isEmpty) {
      return Left(InputFailure('عنوان المهمة لا يمكن أن يكون فارغاً'));
    }

    // 🌟 إنشاء الكيان هنا
    final newTask = TaskEntity(
      id: DateTime.now().toString(),
      title: title.trim(),
      isCompleted: false,
      assignedPeopleIds: assignedPeopleIds,
      assignedPeopleNames: assignedPeopleNames,
    );

    return await repository.addTask(newTask);
  }
}