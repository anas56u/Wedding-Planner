import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:provider_test/core/errors/Failure.dart';
import '../repositories/people_repository.dart';

@lazySingleton
class EditPersonUseCase {
  final IPeopleRepository repository;

  EditPersonUseCase(this.repository);

  Future<Either<Failure, Unit>> execute(int id, String newName, int newAge) async {
    if (newName.trim().isEmpty) {
      return Left(InputFailure('الاسم لا يمكن أن يكون فارغاً'));
    }
    if (newAge <= 0 || newAge > 120) {
      return Left(InputFailure('العمر غير منطقي'));
    }

    return await repository.editPerson(id, newName.trim(), newAge);
  }
}