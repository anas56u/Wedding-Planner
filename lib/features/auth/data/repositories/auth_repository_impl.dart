import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:provider_test/core/errors/Failure.dart';
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
  Future<Either<Failure, UserEntity>> login(String email, String password, bool rememberMe) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      
      if (rememberMe) {
        // إذا اختار تذكرني، نحفظه
        await localDataSource.cacheUser(userModel);
      } else {
        // إذا لم يختر تذكرني، نمسح أي كاش قديم حتى لا يتذكره بالخطأ
        await localDataSource.clearCachedUser();
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
      await remoteDataSource.saveUserDataToFirestore(userModel);

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
  }@override
  Future<Either<Failure, UserEntity>> checkCachedUser() async {
    try {
      // 1. اقرأ البيانات المحلية أولاً
      final localUser = await localDataSource.getLastCachedUser();
      
      // 2. إذا وجدنا المستخدم في التخزين المحلي، نرجعه مباشرة دون انتظار Firebase
      // (لأن Firebase سيعيد الاتصال بالجلسة في الخلفية تلقائياً)
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
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure( 'فشل في تسجيل الخروج.'));
    }
  }
  @override
    @override
  Future<Either<Failure, UserEntity>> checkEmailVerification() async {
    try {
      // 1. نجلب المستخدم الحالي من فايربيس
      final user = remoteDataSource.currentUser;
      
      if (user != null) {
        // 2. نجبر فايربيس على تحديث حالة الإيميل من السيرفر
        await user.reload(); 
        final updatedUser = remoteDataSource.currentUser;

        // 3. نفحص هل قام بالضغط على الرابط فعلاً؟
        if (updatedUser != null && updatedUser.emailVerified) {
          
          // تحويله إلى الموديل الخاص بنا
          final userModel = UserModel.fromFirebaseUser(updatedUser);

          // 4. تحديث حالته في Firestore
          await remoteDataSource.updateUserVerificationStatusInFirestore(userModel.uid, true);

          // 5. تحديث الكاش المحلي
          await localDataSource.cacheUser(userModel);

          // إرجاع المستخدم المحدث للواجهة
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