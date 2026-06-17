import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.uid,
    required super.email,
    required super.isEmailVerified,
    required super.name,
    required super.age,
  });

  factory UserModel.fromFirebaseUser(User user ,{String? name, int? age}) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      isEmailVerified: user.emailVerified,
      name: name ?? '',
      age: age ?? 0,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      isEmailVerified: json['isEmailVerified'],
      name: json['name'] ?? '', // القيمة الافتراضية إذا لم يكن موجودًا
      age: json['age'] ?? 0,    // القيمة الافتراضية إذا لم

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'isEmailVerified': isEmailVerified,
      'name': name,
      'age': age, 
    };
  }
}