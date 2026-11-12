import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_repository.dart';

/// Closes an issued or reissued reminder the person never confirmed, once the family reviewed it.
class MarkReminderAsMissedUseCase {
  final ReminderRepository repository;

  const new({required this.repository});

  Future<Reminder> execute(String reminderId) {
    return repository.markReminderAsMissed(reminderId);
  }
}
