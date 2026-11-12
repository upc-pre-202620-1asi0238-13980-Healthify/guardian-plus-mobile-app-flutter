import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_repository.dart';

/// Only an issued or reissued reminder can be confirmed.
class ConfirmReminderUseCase {
  final ReminderRepository repository;

  const new({required this.repository});

  Future<Reminder> execute(String reminderId) {
    return repository.confirmReminder(reminderId);
  }
}