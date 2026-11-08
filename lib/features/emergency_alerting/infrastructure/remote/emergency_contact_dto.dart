/// An emergency contact as the platform sends it (EmergencyContactResource).
class EmergencyContactDto {
  final String id;
  final String careRecipientProfileId;
  final String userId;
  final String displayName;
  final String relationship;
  final String phoneNumber;
  final int priorityOrder;
  final bool active;

  const new({
    required this.id,
    required this.careRecipientProfileId,
    required this.userId,
    required this.displayName,
    required this.relationship,
    required this.phoneNumber,
    required this.priorityOrder,
    required this.active,
  });

  factory EmergencyContactDto.fromJson(Map<String, dynamic> json) {
    return EmergencyContactDto(
      id: json['id'],
      careRecipientProfileId: json['careRecipientProfileId'],
      userId: json['userId'],
      displayName: json['displayName'],
      relationship: json['relationship'],
      phoneNumber: json['phoneNumber'],
      priorityOrder: json['priorityOrder'],
      active: json['active'],
    );
  }
}
