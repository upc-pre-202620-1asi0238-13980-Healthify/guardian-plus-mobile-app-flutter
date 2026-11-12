import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/emergency_contact_dto.dart';

extension EmergencyContactDtoMapper on EmergencyContactDto {
  EmergencyContact toDomain() {
    return EmergencyContact(
      id: id,
      careRecipientProfileId: careRecipientProfileId,
      userId: userId,
      displayName: displayName,
      relationship: relationship,
      phoneNumber: phoneNumber,
      priorityOrder: priorityOrder,
      active: active,
    );
  }
}
