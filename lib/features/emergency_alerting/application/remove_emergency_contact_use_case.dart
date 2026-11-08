import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact_repository.dart';

/// The platform keeps at least one active contact, so removing the last one fails.
class RemoveEmergencyContactUseCase {
  final EmergencyContactRepository repository;

  const new({required this.repository});

  Future<EmergencyContact> execute(String emergencyContactId) {
    return repository.removeEmergencyContact(emergencyContactId);
  }
}
