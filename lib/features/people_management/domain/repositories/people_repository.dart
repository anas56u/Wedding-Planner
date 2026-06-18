import 'package:dartz/dartz.dart';
import 'package:provider_test/core/errors/failure.dart' show Failure;
import '../entities/person_entity.dart';

abstract class IPeopleRepository {
  Future<Either<Failure, List<PersonEntity>>> getPeople();

  Future<Either<Failure, Unit>> editPerson(int id, String newName, int newAge);

  Future<Either<Failure, Unit>> toggleSelection(int id);
}