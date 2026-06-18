class UserEntity {
  final String uid;
  final String email;
  final bool isEmailVerified;
  final String name;
  final int age;     
  UserEntity({
    required this.uid,
    required this.email,
    required this.isEmailVerified, required this.name, required this.age,
  });
}