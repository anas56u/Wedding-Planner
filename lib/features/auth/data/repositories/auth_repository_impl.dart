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
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      
      await localDataSource.cacheUser(userModel);
      
      return Right(userModel);
    } catch (e) {
     
      return Left(ServerFailure( 'فشل في تسجيل الدخول، تأكد من بياناتك.')); 
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp(String email, String password) async {
    try {
      final userModel = await remoteDataSource.signUp(email, password);
      // ملاحظة: عادة لا نحفظ الجلسة في الـ signUp إذا كنا ننتظر التحقق من الإيميل أولاً
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
      // نحاول جلب المستخدم المحفوظ محلياً عند فتح التطبيق
      final localUser = await localDataSource.getLastCachedUser();
      return Right(localUser);
    } catch (e) {
      // إذا لم يكن مسجلاً، نرجع فشل يخبرنا أنه لا يوجد بيانات محفوظة
      return Left(CacheFailure( 'لا يوجد مستخدم مسجل.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // نمسح الجلسة من Firebase ومن التخزين المحلي
      await remoteDataSource.logout();
      await localDataSource.clearCachedUser();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure( 'فشل في تسجيل الخروج.'));
    }
  }
}