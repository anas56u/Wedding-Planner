import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/Failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
@lazySingleton
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  // أضفنا bool rememberMe هنا ونمررها للـ repository
  Future<Either<Failure, UserEntity>> call(String email, String password, bool rememberMe) async {
    return await repository.login(email, password, rememberMe);
  }
}