import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:provider_test/core/errors/failure.dart';
import '../repositories/people_repository.dart';

@lazySingleton
class TogglePersonSelectionUseCase {
  final IPeopleRepository repository;

  TogglePersonSelectionUseCase(this.repository);

  Future<Either<Failure, Unit>> execute(int id) async {
    if (id <= 0) {
      return Left(InputFailure('معرف الشخص غير صالح'));
    }
    return await repository.toggleSelection(id);
  }
}