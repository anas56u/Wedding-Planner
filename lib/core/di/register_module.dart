import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // لا تنسَ هذا الاستدعاء
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  http.Client get client => http.Client();

  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  // تسجيل خدمة الإشعارات الخاصة بفايربيس هنا
  @lazySingleton
  FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;

  @preResolve 
  @lazySingleton
  Future<SharedPreferences> get sharedPreferences => SharedPreferences.getInstance();
}