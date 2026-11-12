import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/mappers/reminder_enums_mapper.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/reminder_dto.dart';

extension ReminderDtoMapper on ReminderDto {
  Reminder toDomain() {
    return Reminder(
      id: id,
      personUnderCareId: personUnderCareId,
      type: ReminderTypeMapper.fromApi(type),
      title: title,
      dosage: dosage,
      instructions: instructions,
      location: location,
      durationMinutes: durationMinutes,
      scheduledTime: DateTime.parse(scheduledTime).toLocal(),
      leadTimeMinutes: leadTimeMinutes ?? 0,
      confirmedAt: confirmedAt != null ? DateTime.parse(confirmedAt!).toLocal() : null,
      status: ReminderStatusMapper.fromApi(status),
    );
  }
}
