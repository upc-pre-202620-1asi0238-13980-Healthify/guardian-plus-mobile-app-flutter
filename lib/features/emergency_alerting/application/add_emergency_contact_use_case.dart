import 'package:guardian_plus_app/core/id/random_uuid.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact_repository.dart';

class AddEmergencyContactUseCase {
  final EmergencyContactRepository repository;

  const new({required this.repository});

  /// The platform links every contact to a Care Circle member account; each new contact is a new member.
  Future<EmergencyContact> execute({
    required String careRecipientProfileId,
    required String displayName,
    required String relationship,
    required String phoneNumber,
  }) {
    return repository.addEmergencyContact(
      careRecipientProfileId: careRecipientProfileId,
      userId: randomUuid(),
      displayName: displayName.trim(),
      relationship: relationship.trim(),
      phoneNumber: phoneNumber.trim(),
    );
  }
}
