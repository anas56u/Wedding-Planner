import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/Failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class CheckEmailVerificationUseCase {
  final AuthRepository repository;

  CheckEmailVerificationUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.checkEmailVerification();
  }
}