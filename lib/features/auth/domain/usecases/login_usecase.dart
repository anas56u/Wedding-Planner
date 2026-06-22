import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
@lazySingleton
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);
  Future<Either<Failure, UserEntity>> call(String email, String password, bool rememberMe) async {
    return await repository.login(email, password, rememberMe);
  }
}