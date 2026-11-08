/// Who is using the app and whom they care for: the Care Circle member (IAM's user account) and the person
/// under their care.
///
/// [callNumber] is the phone the "call" buttons dial: the care recipient's first emergency contact, since
/// Profile keeps no phone of the care recipient. It is null while there is no emergency contact.
class CareContext {
  final String userAccountId;
  final String userFullName;
  final String careRecipientProfileId;
  final String careRecipientName;
  final String? callNumber;

  const new({
    required this.userAccountId,
    required this.userFullName,
    required this.careRecipientProfileId,
    required this.careRecipientName,
    this.callNumber,
  });

  String get userFirstName => userFullName.split(' ').first;

  String get careRecipientFirstName => careRecipientName.split(' ').first;

  CareContext copyWith({String? Function()? callNumber}) {
    return CareContext(
      userAccountId: userAccountId,
      userFullName: userFullName,
      careRecipientProfileId: careRecipientProfileId,
      careRecipientName: careRecipientName,
      callNumber: callNumber != null ? callNumber() : this.callNumber,
    );
  }
}
