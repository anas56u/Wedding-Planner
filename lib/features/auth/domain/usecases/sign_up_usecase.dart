import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/Failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
@lazySingleton
class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String email, String password ,String name, int age) async {
    return await repository.signUp(email, password, name,  age);
  }
}