import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:provider_test/core/errors/failure.dart';
import '../repositories/tasks_repository.dart';

@lazySingleton
class ToggleTaskCompletionUseCase {
  final ITasksRepository repository;

  ToggleTaskCompletionUseCase(this.repository);

  Future<Either<Failure, Unit>> execute(String id) async {
    if (id.isEmpty) {
      return Left(InputFailure('معرف المهمة غير صالح'));
    }
    return await repository.toggleTaskCompletion(id);
  }
}