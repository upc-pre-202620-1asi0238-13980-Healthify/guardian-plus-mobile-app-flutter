/// A Care Circle member who receives the alerts of a person under care, in escalation order.
class EmergencyContact {
  final String id;
  final String careRecipientProfileId;
  final String userId;
  final String displayName;
  final String relationship;
  final String phoneNumber;
  // 1 is the primary contact; the rest are secondary contacts in escalation order
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
}

extension EmergencyContactList on List<EmergencyContact> {
  /// The contacts that receive alerts, primary first.
  List<EmergencyContact> activeInOrder() {
    return where((contact) => contact.active).toList()
      ..sort((a, b) => a.priorityOrder.compareTo(b.priorityOrder));
  }
}
