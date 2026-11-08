import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/add_emergency_contact_request_dto.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/emergency_contact_dto.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/reorder_emergency_contacts_request_dto.dart';

class EmergencyContactApi {
  final ApiClient client;

  const new({required this.client});

  Future<List<EmergencyContactDto>> getEmergencyContacts(String careRecipientProfileId) async {
    final List jsons = await client.get('emergency-contacts/care-recipient/$careRecipientProfileId');
    return jsons.map((json) => EmergencyContactDto.fromJson(json)).toList();
  }

  Future<EmergencyContactDto> addEmergencyContact(AddEmergencyContactRequestDto request) async {
    final json = await client.post('emergency-contacts', body: request.toJson());
    return EmergencyContactDto.fromJson(json);
  }

  Future<List<EmergencyContactDto>> reorderEmergencyContacts(
    String careRecipientProfileId,
    ReorderEmergencyContactsRequestDto request,
  ) async {
    final List jsons = await client.put(
      'emergency-contacts/care-recipient/$careRecipientProfileId/order',
      body: request.toJson(),
    );
    return jsons.map((json) => EmergencyContactDto.fromJson(json)).toList();
  }

  Future<EmergencyContactDto> removeEmergencyContact(String emergencyContactId) async {
    final json = await client.delete('emergency-contacts/$emergencyContactId');
    return EmergencyContactDto.fromJson(json);
  }
}
