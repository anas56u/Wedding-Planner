import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/Failure.dart';
import '../repositories/auth_repository.dart';
@lazySingleton
class SendEmailVerificationUseCase {
  final AuthRepository repository;

  SendEmailVerificationUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.sendEmailVerification();
  }
}