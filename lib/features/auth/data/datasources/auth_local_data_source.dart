import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel userToCache);
  Future<UserModel> getLastCachedUser();
  Future<void> clearCachedUser();
}

const CACHED_USER_KEY = 'CACHED_USER';
@LazySingleton(as: AuthLocalDataSource)

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

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