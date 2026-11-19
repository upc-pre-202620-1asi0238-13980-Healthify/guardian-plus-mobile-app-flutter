class UserProfile {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  const UserProfile({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });

  String get fullName => '$firstName $lastName'.trim();
}
