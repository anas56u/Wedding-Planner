import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failure.dart'; // تأكد من مسار ملف الـ Failure
import '../repositories/auth_repository.dart';

@lazySingleton
class UpdateUserInfoUseCase {
  final AuthRepository repository;

  UpdateUserInfoUseCase(this.repository);

  // نستخدم دالة call لكي نستدعي الكلاس مباشرة وكأنه دالة
  Future<Either<Failure, void>> call(String uid, String name, int age) async {
    return await repository.updateUserData(uid, name, age);
  }
}