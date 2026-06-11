import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:provider_test/core/errors/Failure.dart';
import '../entities/person_entity.dart';
import '../repositories/people_repository.dart';

@lazySingleton
class GetPeopleUseCase {
  final IPeopleRepository repository;

  GetPeopleUseCase(this.repository);

  Future<Either<Failure, List<PersonEntity>>> execute() async {
    return await repository.getPeople();
  }
}