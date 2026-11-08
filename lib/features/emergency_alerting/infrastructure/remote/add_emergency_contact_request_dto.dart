class AddEmergencyContactRequestDto {
  final String careRecipientProfileId;
  final String userId;
  final String displayName;
  final String relationship;
  final String phoneNumber;

  const new({
    required this.careRecipientProfileId,
    required this.userId,
    required this.displayName,
    required this.relationship,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'careRecipientProfileId': careRecipientProfileId,
      'userId': userId,
      'displayName': displayName,
      'relationship': relationship,
      'phoneNumber': phoneNumber,
    };
  }
}
