import 'package:dartz/dartz.dart';
import 'package:provider_test/core/errors/Failure.dart';
import '../entities/task_entity.dart';


abstract class ITasksRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasks();

  Future<Either<Failure, TaskEntity>> addTask(TaskEntity task);

  Future<Either<Failure, Unit>> deleteTask(String id);

  Future<Either<Failure, Unit>> toggleTaskCompletion(String id);
}