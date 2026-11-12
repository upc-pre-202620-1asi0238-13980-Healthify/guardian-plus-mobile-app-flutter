import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_repository.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/schedule_reminder_request.dart';

class ScheduleReminderUseCase {
  final ReminderRepository repository;

  const new({required this.repository});

  Future<Reminder> execute(ScheduleReminderRequest request) {
    return repository.scheduleReminder(request);
  }
}