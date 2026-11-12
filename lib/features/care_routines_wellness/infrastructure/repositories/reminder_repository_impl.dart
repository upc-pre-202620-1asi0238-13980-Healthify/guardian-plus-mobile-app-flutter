import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_repository.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_type.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/schedule_reminder_request.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/mappers/reminder_enums_mapper.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/mappers/reminder_mapper.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/recurrence_dto.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/reminder_api.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/schedule_reminder_request_dto.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderApi api;

  const new({required this.api});

  @override
  Future<List<Reminder>> getReminders(
    String personUnderCareId, {
    DateTime? from,
    DateTime? to,
    ReminderType? type,
  }) async {
    final dtos = await api.getReminders(
      personUnderCareId,
      from: from?.toUtc().toIso8601String(),
      to: to?.toUtc().toIso8601String(),
      type: type?.toApi(),
    );
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<Reminder> scheduleReminder(ScheduleReminderRequest request) async {
    final dto = await api.scheduleReminder(
      ScheduleReminderRequestDto(
        personUnderCareId: request.personUnderCareId,
        type: request.type.toApi(),
        scheduledTime: request.scheduledTime.toUtc().toIso8601String(),
        title: request.title.trim(),
        dosage: _blankToNull(request.dosage),
        instructions: _blankToNull(request.instructions),
        location: _blankToNull(request.location),
        durationMinutes: request.durationMinutes,
        leadTimeMinutes: request.leadTimeMinutes,
        recurrence: RecurrenceDto(
          frequency: request.frequency.toApi(),
          daysOfWeek: request.daysOfWeek.isEmpty ? null : request.daysOfWeek.map(DayOfWeekMapper.toApi).toList(),
        ),
      ),
    );
    return dto.toDomain();
  }

  @override
  Future<Reminder> confirmReminder(String reminderId) async {
    final dto = await api.confirmReminder(reminderId);
    return dto.toDomain();
  }

  @override
  Future<Reminder> markReminderAsMissed(String reminderId) async {
    final dto = await api.markReminderAsMissed(reminderId);
    return dto.toDomain();
  }

  @override
  Future<Reminder> cancelReminder(String reminderId) async {
    final dto = await api.cancelReminder(reminderId);
    return dto.toDomain();
  }

  // Optional texts left blank are not sent
  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
