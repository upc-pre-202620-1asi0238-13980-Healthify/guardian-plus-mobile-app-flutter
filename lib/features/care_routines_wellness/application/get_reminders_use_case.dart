import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_repository.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_type.dart';

class GetRemindersUseCase {
  final ReminderRepository repository;

  const new({required this.repository});

  Future<List<Reminder>> execute(
    String personUnderCareId, {
    DateTime? from,
    DateTime? to,
    ReminderType? type,
  }) {
    return repository.getReminders(personUnderCareId, from: from, to: to, type: type);
  }
}