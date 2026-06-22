import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/auth_repository.dart';

@injectable
class DeleteAccountWithBiometricUseCase {
  final AuthRepository repository;

  DeleteAccountWithBiometricUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.deleteAccountWithBiometric();
  }
}