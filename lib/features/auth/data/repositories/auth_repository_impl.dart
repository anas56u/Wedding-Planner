import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:provider_test/core/errors/Failure.dart';
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
  Future<Either<Failure, UserEntity>> login(String email, String password, bool rememberMe) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      
      if (rememberMe) {
        await localDataSource.cacheUser(userModel);
      }
      
      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure('فشل في تسجيل الدخول، تأكد من بياناتك.')); 
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp(String email, String password) async {
    try {
      final userModel = await remoteDataSource.signUp(email, password);
      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure( 'حدث خطأ أثناء إنشاء الحساب.'));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure( 'فشل في إرسال البريد الإلكتروني.'));
    }
  }
@override
  Future<Either<Failure, UserEntity>> checkCachedUser() async {
    try {
      // 1. اقرأ البيانات المحلية أولاً
      final localUser = await localDataSource.getLastCachedUser();
      
      // 2. تأكد أن Firebase لا يزال يحتفظ بالجلسة النشطة
final firebaseUser = remoteDataSource.currentUser;      
      if (firebaseUser != null) {
        return Right(localUser);
      } else {
        throw Exception('انتهت جلسة Firebase');
      }
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
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure( 'فشل في تسجيل الخروج.'));
    }
  }
}