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
  Future<Either<Failure, void>> enableBiometric(String email, String password) async {
    try {
      // 1. نتأكد أولاً أن الإيميل والباسورد صحيحان (تسجيل دخول وهمي للتحقق)
      // هذه الخطوة مهمة جداً أمنياً حتى لا نحفظ باسورد خاطئ في التخزين الآمن
      await remoteDataSource.login(email, password);
      
      // 2. إذا نجح، نقوم بمسح بيانات "تذكرني" العادية
      await localDataSource.clearCachedUser();
      
      // 3. نحفظ البيانات في التخزين الآمن
      await localDataSource.saveSecureCredentials(email, password);
      
      // 4. نفعل حالة البصمة
      await localDataSource.setBiometricEnabled(true);
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('فشل تفعيل البصمة، تأكد من كلمة المرور.'));
    }
  }

  @override
  Future<Either<Failure, void>> disableBiometric() async {
    try {
      // مسح البيانات من التخزين الآمن وتعطيل الحالة
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
      // 1. نجلب البيانات المشفرة
      final credentials = await localDataSource.getSecureCredentials();
      
      if (credentials != null) {
        final email = credentials['email']!;
        final password = credentials['password']!;
        
        // 2. نسجل الدخول في فايربيس باستخدامها
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
      // مسح المستخدم من الذاكرة المحلية
      await localDataSource.clearCachedUser();
      return const Right(null);
    } catch (e) {
      if (e.toString().contains('requires-recent-login')) {
        return Left(ServerFailure('لأسباب أمنية، يرجى تسجيل الخروج ثم تسجيل الدخول مجدداً قبل محاولة حذف حسابك.'));
      }
      return Left(ServerFailure('حدث خطأ أثناء محاولة حذف الحساب.'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserData(String uid, String name, int age) async {
    try {
      // 1. تحديث البيانات في فايربيس
      await remoteDataSource.updateUserData(uid, name, age);

      // 2. تحديث الكاش المحلي (أفضل ممارسة لتجنب إعادة تحميل البيانات)
      try {
        final cachedUser = await localDataSource.getLastCachedUser();
        // إنشاء كائن جديد بنفس البيانات القديمة ولكن مع الاسم والعمر الجديدين
        final updatedUserModel = UserModel(
          uid: cachedUser.uid,
          email: cachedUser.email,
          isEmailVerified: cachedUser.isEmailVerified,
          name: name,
          age: age,
        );
        await localDataSource.cacheUser(updatedUserModel);
      } catch (e) {
        // إذا فشل تحديث الكاش لسبب ما، نتجاهله لأن البيانات الأساسية تم حفظها
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء محاولة تحديث البيانات.'));
    }
  }
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
  Future<Either<Failure, UserEntity>> signUp(String email, String password ,String name, int age) async {
    try {
      final userModel = await remoteDataSource.signUp(email, password ,name, age);
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
  }
  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null); // نجاح العملية
    } catch (e) {
      // إرجاع رسالة خطأ واضحة في حال الفشل
      return Left(ServerFailure('حدث خطأ أثناء إرسال رابط استعادة كلمة المرور. تأكد من صحة البريد الإلكتروني.'));
    }
  }
  
  @override
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