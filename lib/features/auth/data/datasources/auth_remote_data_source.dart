import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signUp(String email, String password);
  Future<void> sendEmailVerification();
  Future<void> logout();
  User? get currentUser;
  Future<void> saveUserDataToFirestore(UserModel user);
  Future<void> updateUserVerificationStatusInFirestore(
    String uid,
    bool isVerified,
  );
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  @override
  User? get currentUser => firebaseAuth.currentUser;

  AuthRemoteDataSourceImpl({required this.firebaseAuth, required this.firestore});
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
  Future<UserModel> signUp(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel.fromFirebaseUser(userCredential.user!);
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
