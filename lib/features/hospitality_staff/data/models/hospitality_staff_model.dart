import 'package:provider_test/features/hospitality_staff/domain/entities/hospitality_staff_entity.dart';

class HospitalityStaffModel extends HospitalityStaffEntity {
  HospitalityStaffModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.age,
    required super.gender,
    required super.email,
    required super.phone,
    required super.imageUrl,
  });

  factory HospitalityStaffModel.fromJson(Map<String, dynamic> json) {
    return HospitalityStaffModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      age: json['age'],
      gender: json['gender'],
      email: json['email'],
      phone: json['phone'],
      imageUrl: json['image'],
    );
  }

  @override
  HospitalityStaffModel copyWith({
    String? firstName,
  }) {
    return HospitalityStaffModel(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName,
      age: age,
      gender: gender,
      email: email,
      phone: phone,
      imageUrl: imageUrl,
    );
  }
}

