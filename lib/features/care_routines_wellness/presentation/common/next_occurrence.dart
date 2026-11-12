import 'package:guardian_plus_app/features/care_routines_wellness/domain/local_time.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/recurrence_frequency.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_day.dart';

/// First occurrence of a routine set for [time]: today if that time has not passed yet, otherwise the next
/// day; for "Días específicos", the next of the chosen [days]. The platform repeats it from there.
DateTime firstOccurrence({
  required LocalTime time,
  required RecurrenceFrequency frequency,
  required Set<int> days,
  required DateTime now,
}) {
  var candidate = atTime(now, time);
  if (!candidate.isAfter(now)) candidate = _nextDay(candidate, time);
  if (frequency == RecurrenceFrequency.weekly && days.isNotEmpty) {
    while (!days.contains(candidate.weekday)) {
      candidate = _nextDay(candidate, time);
    }
  }
  return candidate;
}

// By calendar day, so a daylight saving change does not move the time
DateTime _nextDay(DateTime day, LocalTime time) => DateTime(day.year, day.month, day.day + 1, time.hour, time.minute);
