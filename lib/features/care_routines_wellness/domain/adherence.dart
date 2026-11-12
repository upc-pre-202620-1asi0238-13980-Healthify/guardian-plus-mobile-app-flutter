import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_type.dart';

/// How many of the reminders of one type that reached the person were confirmed in a period.
class Adherence {
  final ReminderType type;
  final DateTime from;
  final DateTime to;
  final int due;
  final int confirmed;
  final int percentage;
  // One entry for every day of the period
  final List<DailyAdherence> days;

  const new({
    required this.type,
    required this.from,
    required this.to,
    required this.due,
    required this.confirmed,
    required this.percentage,
    this.days = const [],
  });

  // 0 % with nothing due means "no doses scheduled", not "none taken"
  bool get hasDueReminders => due > 0;
}

class DailyAdherence {
  final DateTime date;
  final int due;
  final int confirmed;
  final int percentage;

  const new({
    required this.date,
    required this.due,
    required this.confirmed,
    required this.percentage,
  });
}