import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signUp(String email, String password ,String name, int age);
  Future<void> sendEmailVerification();
  Future<void> logout();
  User? get currentUser;
  Future<void> saveUserDataToFirestore(UserModel user);
  Future<void> updateUserVerificationStatusInFirestore(
    String uid,
    bool isVerified,
  );
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updateUserData(String uid, String name, int age);
  Future<void> deleteAccount( String password);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  @override
  User? get currentUser => firebaseAuth.currentUser;

  AuthRemoteDataSourceImpl({required this.firebaseAuth, required this.firestore});

@override
  Future<void> deleteAccount(String password) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user != null && user.email != null) {
        // 1. إعادة التحقق من الهوية (Re-authentication) لمنع خطأ فايربيس
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        // إذا كانت كلمة المرور خطأ، سيتوقف الكود هنا ويرمي Exception
        await user.reauthenticateWithCredential(credential);

        // 2. الآن نحن متأكدون 100% أن الجلسة صالحة، نحذف من Firestore
        await firestore.collection('users').doc(user.uid).delete();
        
        // 3. ثم نحذف الحساب من Firebase Auth ولن يرفض العملية أبداً
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('كلمة المرور غير صحيحة.');
      } else {
        throw Exception('حدث خطأ من الخادم: ${e.message}');
      }
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع أثناء الحذف.');
    }
  }
  @override
  Future<void> updateUserData(String uid, String name, int age) async {
    try {
      // نستخدم update لتعديل حقول محددة فقط في الوثيقة
      await firestore.collection('users').doc(uid).update({
        'name': name,
        'age': age,
      });
    } catch (e) {
      throw Exception(); // سيلتقط الـ Repository هذا الخطأ
    }
  }
// 2. دالة تحديث حالة التحقق فقط
  @override
  Future<void> updateUserVerificationStatusInFirestore(String uid, bool isVerified) async {
    // نستخدم update بدلاً من set لكي لا نمسح باقي بيانات المستخدم
    await firestore.collection('users').doc(uid).update({
      'isEmailVerified': isVerified,
    });
  }
  @override
  Future<void> saveUserDataToFirestore (UserModel user) async{
    await  firestore.collection("users").doc(user.uid).set(user.toJson());
    
  }
@override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      // نمرر الخطأ للـ Repository ليتعامل معه
      throw Exception(); 
    }
  }
  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel.fromFirebaseUser(userCredential.user!);
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<UserModel> signUp(String email, String password, String name, int age) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,

      );
      return UserModel.fromFirebaseUser(userCredential.user! , name: name, age: age);
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }
}
