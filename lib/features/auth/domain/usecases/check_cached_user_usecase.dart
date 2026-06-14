import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class CheckCachedUserUseCase {
  final AuthRepository repository;

  CheckCachedUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.checkCachedUser();
  }
}