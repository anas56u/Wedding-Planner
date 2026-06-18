import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:provider_test/core/errors/failure.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/tasks_repository.dart';
import '../datasources/tasks_local_data_source.dart';
import '../models/task_model.dart';

@LazySingleton(as: ITasksRepository)
class TasksRepositoryImpl implements ITasksRepository {
  final ITasksLocalDataSource localDataSource;

  TasksRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() async {
    try {
      final tasks = await localDataSource.getTasks();
      return Right(List<TaskEntity>.from(tasks));
    } catch (e) {
      return Left(CacheFailure('فشل في جلب المهام'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> addTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      final addedTask = await localDataSource.addTask(taskModel);
      return Right(addedTask);
    } catch (e) {
      return Left(CacheFailure('فشل في إضافة المهمة'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTask(String id) async {
    try {
      await localDataSource.deleteTask(id);
      return const Right(unit); 
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleTaskCompletion(String id) async {
    try {
      await localDataSource.toggleTaskCompletion(id);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}