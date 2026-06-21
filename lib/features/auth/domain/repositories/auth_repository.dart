import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signUp(
    String email,
    String password,
    String name,
    int age,
  );
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
    bool rememberMe,
  );
  Future<Either<Failure, void>> sendEmailVerification();

  Future<Either<Failure, UserEntity>> checkCachedUser();

  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Future<Either<Failure, UserEntity>> checkEmailVerification();
  Future<Either<Failure, void>> updateUserData(
    String uid,
    String name,
    int age,
  );
  Future<Either<Failure, void>> deleteAccount(String password);
  Future<Either<Failure, void>> enableBiometric(String email, String password);
  Future<Either<Failure, void>> disableBiometric();
  Future<Either<Failure, UserEntity>> loginWithBiometric();
  Future<Either<Failure, bool>> isBiometricEnabled();
}
