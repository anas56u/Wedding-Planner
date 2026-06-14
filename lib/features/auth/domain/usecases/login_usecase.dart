import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  // نقوم بحقن (Inject) الـ Repository هنا
  LoginUseCase(this.repository);

  // استخدام دالة call يجعل الكلاس قابل للاستدعاء كأنه دالة
  Future<Either<Failure, UserEntity>> call(String email, String password) async {
    return await repository.login(email, password);
  }
}