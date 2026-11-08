import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact.dart';

abstract class EmergencyContactRepository {
  Future<List<EmergencyContact>> getEmergencyContacts(String careRecipientProfileId);

  Future<EmergencyContact> addEmergencyContact({
    required String careRecipientProfileId,
    required String userId,
    required String displayName,
    required String relationship,
    required String phoneNumber,
  });

  Future<EmergencyContact> removeEmergencyContact(String emergencyContactId);

  /// [orderedIds] must list every active contact exactly once; the first one becomes the primary contact.
  Future<List<EmergencyContact>> reorderEmergencyContacts({
    required String careRecipientProfileId,
    required List<String> orderedIds,
  });
}
