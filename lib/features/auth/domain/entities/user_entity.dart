class UserEntity {
  final String uid;
  final String email;
  final bool isEmailVerified;

  UserEntity({
    required this.uid,
    required this.email,
    required this.isEmailVerified,
  });
}