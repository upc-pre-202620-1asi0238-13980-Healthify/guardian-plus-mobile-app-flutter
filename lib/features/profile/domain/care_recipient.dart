class CareRecipient {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime birthDate;

  const CareRecipient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
  });

  String get fullName => '$firstName $lastName'.trim();
}
