import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/recurrence_dto.dart';

/// Same body as the platform's ScheduleReminderResource.
class ScheduleReminderRequestDto {
  final String personUnderCareId;
  final String type;
  final String scheduledTime;
  final String title;
  final String? dosage;
  final String? instructions;
  final String? location;
  final int? durationMinutes;
  final int leadTimeMinutes;
  final RecurrenceDto recurrence;

  const new({
    required this.personUnderCareId,
    required this.type,
    required this.scheduledTime,
    required this.title,
    required this.dosage,
    required this.instructions,
    required this.location,
    required this.durationMinutes,
    required this.leadTimeMinutes,
    required this.recurrence,
  });

  Map<String, dynamic> toJson() {
    return {
      'personUnderCareId': personUnderCareId,
      'type': type,
      'scheduledTime': scheduledTime,
      'title': title,
      'dosage': ?dosage,
      'instructions': ?instructions,
      'location': ?location,
      'durationMinutes': ?durationMinutes,
      'leadTimeMinutes': leadTimeMinutes,
      'recurrence': recurrence.toJson(),
    };
  }
}
