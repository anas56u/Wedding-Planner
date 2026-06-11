class HospitalityStaffEntity {
  final int id;
  final String firstName;
  final String lastName;
  final int age;
  final String gender;
  final String email;
  final String phone;
  final String imageUrl;

  HospitalityStaffEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.gender,
    required this.email,
    required this.phone,
    required this.imageUrl,
  });

  HospitalityStaffEntity copyWith({
    String? firstName,
  }) {
    return HospitalityStaffEntity(
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
