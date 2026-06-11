import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:provider_test/core/errors/Failure.dart';
import '../entities/task_entity.dart';
import '../repositories/tasks_repository.dart';

@lazySingleton
class GetTasksUseCase {
  final ITasksRepository repository;

  GetTasksUseCase(this.repository);

  Future<Either<Failure, List<TaskEntity>>> execute() async {
    return await repository.getTasks();
  }
}