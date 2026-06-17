import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/Failure.dart';
import '../repositories/auth_repository.dart';

@injectable
class SendPasswordResetUseCase {
  final AuthRepository repository;

  SendPasswordResetUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) {
    return repository.sendPasswordResetEmail(email);
  }
}