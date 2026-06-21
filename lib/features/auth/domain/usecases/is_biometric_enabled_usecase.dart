import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/auth_repository.dart';

@injectable
class IsBiometricEnabledUseCase {
  final AuthRepository repository;

  IsBiometricEnabledUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.isBiometricEnabled();
  }
}