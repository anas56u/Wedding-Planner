import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:provider_test/core/errors/Failure.dart';
import '../../domain/entities/person_entity.dart';
import '../../domain/repositories/people_repository.dart';
import '../datasources/people_local_data_source.dart';
import '../datasources/people_remote_data_source.dart'; 

@LazySingleton(as: IPeopleRepository)
class PeopleRepositoryImpl implements IPeopleRepository {
  final IPeopleLocalDataSource localDataSource;
  final IPeopleRemoteDataSource remoteDataSource; 

  PeopleRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });


@override
Future<Either<Failure, List<PersonEntity>>> getPeople() async {
  try {
    final remoteModels = await remoteDataSource.getPeopleFromApi();
    
    localDataSource.cachePeople(remoteModels);
    
    return Right(List<PersonEntity>.from(remoteModels));
  } catch (apiError) {
    try {
      final localModels = await localDataSource.getPeople();
      return Right(List<PersonEntity>.from(localModels));
    } catch (localError) {
      return Left(CacheFailure('تعذر جلب البيانات من الإنترنت ومن الملف المحلي'));
    }
  }
}

  @override
  Future<Either<Failure, Unit>> editPerson(int id, String newName, int newAge) async {
    try {
      await localDataSource.editPerson(id, newName, newAge);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('تعذر تعديل بيانات الشخص'));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleSelection(int id) async {
    try {
      await localDataSource.toggleSelection(id);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('تعذر تغيير حالة الشخص'));
    }
  }
}