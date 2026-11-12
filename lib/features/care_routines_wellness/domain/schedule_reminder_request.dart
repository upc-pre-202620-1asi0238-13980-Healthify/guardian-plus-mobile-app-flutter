import 'package:guardian_plus_app/features/care_routines_wellness/domain/recurrence_frequency.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_type.dart';

/// What the family enters to schedule a routine.
class ScheduleReminderRequest {
  final String personUnderCareId;
  final ReminderType type;
  final DateTime scheduledTime;
  final String title;
  final String? dosage;
  final String? instructions;
  final String? location;
  final int? durationMinutes;
  final int leadTimeMinutes;
  final RecurrenceFrequency frequency;
  // Only for weekly, where the platform requires at least one day (DateTime.monday to DateTime.sunday)
  final Set<int> daysOfWeek;

  const new({
    required this.personUnderCareId,
    required this.type,
    required this.scheduledTime,
    required this.title,
    this.dosage,
    this.instructions,
    this.location,
    this.durationMinutes,
    this.leadTimeMinutes = 0,
    this.frequency = RecurrenceFrequency.once,
    this.daysOfWeek = const {},
  });
}