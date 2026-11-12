import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact_repository.dart';

/// Sets the escalation chain: the first contact is the primary one, the rest are secondary contacts.
class ReorderEmergencyContactsUseCase {
  final EmergencyContactRepository repository;

  const new({required this.repository});

  Future<List<EmergencyContact>> execute({
    required String careRecipientProfileId,
    required List<String> orderedIds,
  }) {
    return repository.reorderEmergencyContacts(
      careRecipientProfileId: careRecipientProfileId,
      orderedIds: orderedIds,
    );
  }
}
