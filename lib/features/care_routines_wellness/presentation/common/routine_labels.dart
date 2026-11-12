import 'dart:math';

import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/local_time.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_type.dart';

// Spanish names, as java.time prints them for the "es" locale
const _months = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];
const _shortMonths = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sept', 'oct', 'nov', 'dic'];
const _weekdays = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];

const _minutesPerDay = 1440;

/// "1 vaso" or "2 vasos": Spanish only tells one from the rest.
String plural(int count, String one, String other) => count == 1 ? one : other;

String _twoDigits(int value) => value.toString().padLeft(2, '0');

extension ReminderTypeLabels on ReminderType {
  IconData get icon {
    return switch (this) {
      ReminderType.medication => Icons.medication_outlined,
      ReminderType.appointment => Icons.calendar_today_outlined,
      ReminderType.physicalActivity => Icons.directions_walk,
      ReminderType.hydration => Icons.water_drop_outlined,
    };
  }

  /// The routine a reminder of this type belongs to, e.g. "Medicación".
  String get routineName {
    return switch (this) {
      ReminderType.medication => 'Medicación',
      ReminderType.appointment => 'Citas médicas',
      ReminderType.physicalActivity => 'Actividad ligera',
      ReminderType.hydration => 'Hidratación',
    };
  }
}

extension ReminderLabels on Reminder {
  /// The reminder's own title, or the routine it belongs to when the family did not name it.
  String get displayTitle {
    final title = this.title;
    return title == null || title.trim().isEmpty ? type.routineName : title;
  }

  /// "1 tableta · Después del almuerzo", "Clínica San Gabriel" or "10 minutos", depending on the routine.
  String get detailLine {
    final duration = durationMinutes != null ? '$durationMinutes minutos' : null;
    return [dosage, instructions, location, duration].nonNulls.where((part) => part.trim().isNotEmpty).join(' · ');
  }
}

/// "14:00" on the phone's time zone.
String formatClockTime(DateTime at) {
  final local = at.toLocal();
  return '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
}

/// "22:00" for a time of day.
String formatTimeOfDay(LocalTime time) => '${_twoDigits(time.hour)}:${_twoDigits(time.minute)}';

/// "EN 25 MIN", "EN 2 H", "EN 1 H 20 MIN", or "AHORA" once the time has come.
String timeUntil(DateTime at, DateTime now) {
  final minutes = at.difference(now).inMinutes;
  if (minutes <= 0) return 'AHORA';
  if (minutes < 60) return 'EN $minutes MIN';
  if (minutes % 60 == 0) return 'EN ${minutes ~/ 60} H';
  return 'EN ${minutes ~/ 60} H ${minutes % 60} MIN';
}

bool isSameDay(DateTime a, DateTime b) {
  final first = a.toLocal();
  final second = b.toLocal();
  return first.year == second.year && first.month == second.month && first.day == second.day;
}

/// "hoy", "mañana" or "24 abr" on the phone's time zone.
String dayLabel(DateTime at, DateTime now) {
  final today = now.toLocal();
  if (isSameDay(at, today)) return 'hoy';
  if (isSameDay(at, DateTime(today.year, today.month, today.day + 1))) return 'mañana';
  return formatDayAndMonth(at);
}

/// "24 abr" on the phone's time zone.
String formatDayAndMonth(DateTime at) {
  final local = at.toLocal();
  return '${local.day} ${_shortMonths[local.month - 1]}';
}

/// "MARTES 23", the date of the "HOY" card.
String formatWeekdayAndDay(DateTime at) {
  final local = at.toLocal();
  return '${_weekdays[local.weekday - 1]} ${local.day}'.toUpperCase();
}

/// "12 de mayo".
String formatDayOfMonth(DateTime date) => '${date.day} de ${_months[date.month - 1]}';

/// "12 de mayo 2026", the value of a date field.
String formatFullDate(DateTime date) => '${formatDayOfMonth(date)} ${date.year}';

/// "ABR", the month of an appointment's date tile.
String formatShortMonth(DateTime at) => _shortMonths[at.toLocal().month - 1].toUpperCase();

/// "Lun", "Mar"… for the rows of a weekly history.
String formatShortWeekday(DateTime date) {
  final name = _weekdays[date.toLocal().weekday - 1].substring(0, 3);
  return name[0].toUpperCase() + name.substring(1);
}

/// "L", "M", "X"… the single-letter days under the weekly bars; [weekday] goes from DateTime.monday on.
String weekdayInitial(int weekday) => const ['L', 'M', 'X', 'J', 'V', 'S', 'D'][weekday - 1];

/// 444 → "7 h 24 min".
String formatSleepDuration(int minutes) => '${minutes ~/ 60} h ${minutes % 60} min';

/// "48 s", "1 min 22 s" (seconds matter while it is short), "18 min" or "1 h 5 min".
String formatDuration(int seconds) {
  if (seconds < 60) return '$seconds s';
  if (seconds < 600 && seconds % 60 != 0) return '${seconds ~/ 60} min ${seconds % 60} s';
  if (seconds < 3600) return '${seconds ~/ 60} min';
  return '${seconds ~/ 3600} h ${(seconds % 3600) ~/ 60} min';
}

/// "25 min" or "1 h 5 min" until [at]; never negative.
String durationUntil(DateTime at, DateTime now) => formatDuration(max(at.difference(now).inSeconds, 60));

/// "Ahora", "Hace 40 s", "Hace 1 min", "Hace 2 h" or "Hace 3 d".
String relativeTime(DateTime from, DateTime now) {
  final seconds = max(now.difference(from).inSeconds, 0);
  if (seconds < 5) return 'Ahora';
  if (seconds < 60) return 'Hace $seconds s';
  if (seconds < 3600) return 'Hace ${seconds ~/ 60} min';
  if (seconds < 86400) return 'Hace ${seconds ~/ 3600} h';
  return 'Hace ${seconds ~/ 86400} d';
}

/// "Aviso 1 hora antes", "Aviso 1 día antes", "Aviso 30 min antes" or "Sin aviso previo".
String leadTimeLabel(int minutes) {
  if (minutes <= 0) return 'Sin aviso previo';
  if (minutes % _minutesPerDay == 0) {
    final days = minutes ~/ _minutesPerDay;
    return plural(days, 'Aviso $days día antes', 'Aviso $days días antes');
  }
  if (minutes % 60 == 0) {
    final hours = minutes ~/ 60;
    return plural(hours, 'Aviso $hours hora antes', 'Aviso $hours horas antes');
  }
  return 'Aviso $minutes min antes';
}

/// "Cada hora" or "Cada 2 horas".
String hydrationIntervalLabel(int hours) => hours == 1 ? 'Cada hora' : 'Cada $hours horas';

/// "Buen progreso" from 80%, "Regular" from 50%, "Requiere atención" below.
String adherenceLabel(int percentage) {
  if (percentage >= 80) return 'Buen progreso';
  if (percentage >= 50) return 'Regular';
  return 'Requiere atención';
}
