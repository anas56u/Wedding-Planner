import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/auth_repository.dart';

@injectable
class DisableBiometricUseCase {
  final AuthRepository repository;

  DisableBiometricUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.disableBiometric();
  }
}