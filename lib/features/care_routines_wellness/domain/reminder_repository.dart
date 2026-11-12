import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_type.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/schedule_reminder_request.dart';

abstract class ReminderRepository {
  /// Reminders ordered by scheduled time, optionally narrowed to [from, to) and to one [type].
  Future<List<Reminder>> getReminders(
    String personUnderCareId, {
      DateTime? from,
      DateTime? to,
      ReminderType? type,
    });

  Future<Reminder> scheduleReminder(ScheduleReminderRequest request);

  /// Only an issued or reissued reminder can be confirmed.
  Future<Reminder> confirmReminder(String reminderId);

  /// Closes an issued or reissued reminder the person never confirmed, once the family reviewed it.
  Future<Reminder> markReminderAsMissed(String reminderId);

  /// Cancelling the pending occurrence of a recurring reminder stops its series.
  Future<Reminder> cancelReminder(String reminderId);
}