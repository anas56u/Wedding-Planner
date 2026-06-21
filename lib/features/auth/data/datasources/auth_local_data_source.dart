import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel userToCache);
  Future<UserModel> getLastCachedUser();
  Future<void> clearCachedUser();
  Future<void> saveSecureCredentials(String email, String password);
  Future<Map<String, String>?> getSecureCredentials();
  Future<void> clearSecureCredentials();
  Future<void> setBiometricEnabled(bool value);
  Future<bool> isBiometricEnabled();
}

const CACHED_USER_KEY = 'CACHED_USER';
const SECURE_EMAIL_KEY = 'SECURE_EMAIL';
const SECURE_PASSWORD_KEY = 'SECURE_PASSWORD';
const BIOMETRIC_ENABLED_KEY = 'BIOMETRIC_ENABLED';
@LazySingleton(as: AuthLocalDataSource)

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.sharedPreferences }): secureStorage = const FlutterSecureStorage();
@override
  Future<void> saveSecureCredentials(String email, String password) async {
    await secureStorage.write(key: SECURE_EMAIL_KEY, value: email);
    await secureStorage.write(key: SECURE_PASSWORD_KEY, value: password);
  }
  @override
  Future<Map<String, String>?> getSecureCredentials() async {
    final email = await secureStorage.read(key: SECURE_EMAIL_KEY);
    final password = await secureStorage.read(key: SECURE_PASSWORD_KEY);
    
    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }
  @override
  Future<void> clearSecureCredentials() async {
    await secureStorage.delete(key: SECURE_EMAIL_KEY);
    await secureStorage.delete(key: SECURE_PASSWORD_KEY);
  }
  @override
  Future<void> setBiometricEnabled(bool value) async {
    await secureStorage.write(key: BIOMETRIC_ENABLED_KEY, value: value.toString());
  }
  @override
  Future<bool> isBiometricEnabled() async {
    final value = await secureStorage.read(key: BIOMETRIC_ENABLED_KEY);
    return value == 'true';
  }
  @override
  Future<void> cacheUser(UserModel userToCache) async {
    final jsonString = json.encode(userToCache.toJson());
    await sharedPreferences.setString(CACHED_USER_KEY, jsonString);
  }

  @override
  Future<UserModel> getLastCachedUser() {
    final jsonString = sharedPreferences.getString(CACHED_USER_KEY);
    if (jsonString != null) {
      final decodedJson = json.decode(jsonString);
      return Future.value(UserModel.fromJson(decodedJson));
    } else {
      throw Exception(); 
    }
  }

  @override
  Future<void> clearCachedUser() {
    return sharedPreferences.remove(CACHED_USER_KEY);
  }
}