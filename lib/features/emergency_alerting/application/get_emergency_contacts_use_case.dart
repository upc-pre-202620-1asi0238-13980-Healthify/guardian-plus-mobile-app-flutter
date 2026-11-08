import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact_repository.dart';

class GetEmergencyContactsUseCase {
  final EmergencyContactRepository repository;

  const new({required this.repository});

  Future<List<EmergencyContact>> execute(String careRecipientProfileId) {
    return repository.getEmergencyContacts(careRecipientProfileId);
  }
}
