import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_status.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_type.dart';

/// One occurrence of a routine: a dose, an appointment, an activity block or a glass of water.
class Reminder {
  final String id;
  final String personUnderCareId;
  final ReminderType type;
  // "Losartán", "Control de cardiología"; mandatory on the platform, kept optional for older records
  final String? title;
  final String? dosage;
  final String? instructions;
  final String? location;
  final int? durationMinutes;
  final DateTime scheduledTime;
  // How long before scheduledTime the reminder reaches the person, e.g. 60 for "1 hora antes"
  final int leadTimeMinutes;
  final DateTime? confirmedAt;
  final ReminderStatus status;

  const new({required this.id,
    required this.personUnderCareId,
    required this.type,
    required this.title,
    this.dosage,
    this.instructions,
    this.location,
    this.durationMinutes,
    required this.scheduledTime,
    this.leadTimeMinutes = 0,
    this.confirmedAt, 
    required this.status,
    });

  /// Issued (or reissued) and waiting for the person; the only states the platform lets be confirmed.
  bool get canBeConfirmed => status == ReminderStatus.issued || status == ReminderStatus.reissued;
}