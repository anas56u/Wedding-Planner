import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/auth_repository.dart';

@injectable
class EnableBiometricUseCase {
  final AuthRepository repository;

  EnableBiometricUseCase(this.repository);

  Future<Either<Failure, void>> call(String email, String password) async {
    return await repository.enableBiometric(email, password);
  }
}