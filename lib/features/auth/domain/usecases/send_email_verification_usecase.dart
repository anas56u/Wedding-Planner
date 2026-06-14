import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failure.dart';
import '../repositories/auth_repository.dart';

class SendEmailVerificationUseCase {
  final AuthRepository repository;

  SendEmailVerificationUseCase(this.repository);

  // تعيد void في حالة النجاح لأننا لا نحتاج لبيانات عائدة، فقط نتأكد من إرسال الإيميل
  Future<Either<Failure, void>> call() async {
    return await repository.sendEmailVerification();
  }
}