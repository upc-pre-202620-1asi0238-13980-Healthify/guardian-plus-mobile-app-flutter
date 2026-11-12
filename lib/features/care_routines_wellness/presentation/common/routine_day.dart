import 'package:guardian_plus_app/features/care_routines_wellness/domain/local_time.dart';

/// Start of the day of [now] and of the next one, on the phone's time zone: the [from, to) of "today".
(DateTime, DateTime) todayBounds(DateTime now) {
  final local = now.toLocal();
  return (DateTime(local.year, local.month, local.day), DateTime(local.year, local.month, local.day + 1));
}

/// The last seven days, today included, as the platform's adherence endpoint counts them.
(DateTime, DateTime) lastWeek(DateTime now) {
  final local = now.toLocal();
  return (DateTime(local.year, local.month, local.day - 6), DateTime(local.year, local.month, local.day));
}

/// [time] on the day of [day], on the phone's time zone.
DateTime atTime(DateTime day, LocalTime time) {
  final local = day.toLocal();
  return DateTime(local.year, local.month, local.day, time.hour, time.minute);
}
