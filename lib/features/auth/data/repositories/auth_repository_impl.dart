import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:provider_test/core/errors/failure.dart';
import 'package:provider_test/features/auth/data/models/user_model.dart';
import 'package:provider_test/features/auth/domain/entities/user_entity.dart';
import 'package:provider_test/features/auth/domain/repositories/auth_repository.dart';
import 'package:provider_test/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:provider_test/features/auth/data/datasources/auth_remote_data_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  @override
  Future<Either<Failure, bool>> isBiometricEnabled() async {
    try {
      final result = await localDataSource.isBiometricEnabled();
      return Right(result);
    } catch (e) {
      return Left(CacheFailure('فشل في قراءة حالة البصمة من التخزين الآمن.'));
    }
  }

  @override
  Future<Either<Failure, void>> enableBiometric(
    String email,
    String password,
  ) async {
    try {

      await remoteDataSource.login(email, password);


      await localDataSource.clearCachedUser();


      await localDataSource.saveSecureCredentials(email, password);


      await localDataSource.setBiometricEnabled(true);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('فشل تفعيل البصمة، تأكد من كلمة المرور.'));
    }
  }

  @override
  Future<Either<Failure, void>> disableBiometric() async {
    try {

      await localDataSource.clearSecureCredentials();
      await localDataSource.setBiometricEnabled(false);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('حدث خطأ أثناء تعطيل البصمة.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithBiometric() async {
    try {

      final credentials = await localDataSource.getSecureCredentials();

      if (credentials != null) {
        final email = credentials['email']!;
        final password = credentials['password']!;


        final userModel = await remoteDataSource.login(email, password);
        return Right(userModel);
      } else {
        return Left(CacheFailure('لا توجد بيانات محفوظة للبصمة.'));
      }
    } catch (e) {
      return Left(ServerFailure('فشل تسجيل الدخول بالبصمة.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String password) async {
    try {
      await remoteDataSource.deleteAccount(password);

      await localDataSource.clearCachedUser();
      return const Right(null);
    } catch (e) {
      if (e.toString().contains('requires-recent-login')) {
        return Left(
          ServerFailure(
            'لأسباب أمنية، يرجى تسجيل الخروج ثم تسجيل الدخول مجدداً قبل محاولة حذف حسابك.',
          ),
        );
      }
      return Left(ServerFailure('حدث خطأ أثناء محاولة حذف الحساب.'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserData(
    String uid,
    String name,
    int age,
  ) async {
    try {

      await remoteDataSource.updateUserData(uid, name, age);


      try {
        final cachedUser = await localDataSource.getLastCachedUser();

        final updatedUserModel = UserModel(
          uid: cachedUser.uid,
          email: cachedUser.email,
          isEmailVerified: cachedUser.isEmailVerified,
          name: name,
          age: age,
        );
        await localDataSource.cacheUser(updatedUserModel);
      } catch (e) {

      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء محاولة تحديث البيانات.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
    bool rememberMe,
  ) async {
    try {
      final userModel = await remoteDataSource.login(email, password);

      if (rememberMe) {

        await localDataSource.cacheUser(userModel);
      } else {

        await localDataSource.clearCachedUser();
      }

      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure('فشل في تسجيل الدخول، تأكد من بياناتك.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp(
    String email,
    String password,
    String name,
    int age,
  ) async {
    try {
      final userModel = await remoteDataSource.signUp(
        email,
        password,
        name,
        age,
      );
      await remoteDataSource.saveUserDataToFirestore(userModel);

      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء إنشاء الحساب.'));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('فشل في إرسال البريد الإلكتروني.'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } catch (e) {

      return Left(
        ServerFailure(
          'حدث خطأ أثناء إرسال رابط استعادة كلمة المرور. تأكد من صحة البريد الإلكتروني.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> checkCachedUser() async {
    try {

      final localUser = await localDataSource.getLastCachedUser();


      return Right(localUser);
    } catch (e) {
      await remoteDataSource.logout();
      return Left(CacheFailure('لا يوجد مستخدم مسجل.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {

      await remoteDataSource.logout();


      await localDataSource.clearCachedUser();


      await localDataSource.clearSecureCredentials();
      await localDataSource.setBiometricEnabled(false);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('فشل في تسجيل الخروج.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccountWithBiometric() async {
    try {

      final credentials = await localDataSource.getSecureCredentials();

      if (credentials != null) {
        final password = credentials['password']!;


        await remoteDataSource.deleteAccount(password);


        await localDataSource.clearCachedUser();
        await localDataSource.clearSecureCredentials();
        await localDataSource.setBiometricEnabled(false);

        return const Right(null);
      } else {
        return Left(CacheFailure('لا توجد بيانات حيوية محفوظة لحذف الحساب.'));
      }
    } catch (e) {
      if (e.toString().contains('requires-recent-login')) {
        return Left(
          ServerFailure(
            'لأسباب أمنية، يرجى تسجيل الخروج ثم الدخول مجدداً قبل حذف الحساب.',
          ),
        );
      }
      return Left(ServerFailure('حدث خطأ أثناء محاولة حذف الحساب.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> checkEmailVerification() async {
    try {

      final user = remoteDataSource.currentUser;

      if (user != null) {

        await user.reload();
        final updatedUser = remoteDataSource.currentUser;


        if (updatedUser != null && updatedUser.emailVerified) {

          final userModel = UserModel.fromFirebaseUser(updatedUser);


          await remoteDataSource.updateUserVerificationStatusInFirestore(
            userModel.uid,
            true,
          );


          await localDataSource.cacheUser(userModel);


          return Right(userModel);
        } else {
          return Left(ServerFailure('لم يتم التحقق من البريد الإلكتروني بعد.'));
        }
      }
      return Left(ServerFailure('لا يوجد مستخدم مسجل.'));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء فحص حالة التحقق.'));
    }
  }
}
