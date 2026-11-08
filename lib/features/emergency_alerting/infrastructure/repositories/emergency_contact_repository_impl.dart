import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/mappers/emergency_contact_mapper.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/add_emergency_contact_request_dto.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/emergency_contact_api.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/reorder_emergency_contacts_request_dto.dart';

class EmergencyContactRepositoryImpl implements EmergencyContactRepository {
  final EmergencyContactApi api;

  const new({required this.api});

  @override
  Future<List<EmergencyContact>> getEmergencyContacts(String careRecipientProfileId) async {
    final dtos = await api.getEmergencyContacts(careRecipientProfileId);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<EmergencyContact> addEmergencyContact({
    required String careRecipientProfileId,
    required String userId,
    required String displayName,
    required String relationship,
    required String phoneNumber,
  }) async {
    final dto = await api.addEmergencyContact(
      AddEmergencyContactRequestDto(
        careRecipientProfileId: careRecipientProfileId,
        userId: userId,
        displayName: displayName,
        relationship: relationship,
        phoneNumber: phoneNumber,
      ),
    );
    return dto.toDomain();
  }

  @override
  Future<EmergencyContact> removeEmergencyContact(String emergencyContactId) async {
    final dto = await api.removeEmergencyContact(emergencyContactId);
    return dto.toDomain();
  }

  @override
  Future<List<EmergencyContact>> reorderEmergencyContacts({
    required String careRecipientProfileId,
    required List<String> orderedIds,
  }) async {
    final dtos = await api.reorderEmergencyContacts(
      careRecipientProfileId,
      ReorderEmergencyContactsRequestDto(orderedEmergencyContactIds: orderedIds),
    );
    return dtos.map((dto) => dto.toDomain()).toList();
  }
}
