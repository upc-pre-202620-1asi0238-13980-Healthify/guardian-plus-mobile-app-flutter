import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_repository.dart';

/// Cancelling the pending occurrence of a recurring reminder stops its series.
class CancelReminderUseCase {
  final ReminderRepository repository;

  const new({required this.repository});

  Future<Reminder> execute(String reminderId) {
    return repository.cancelReminder(reminderId);
  }
}
