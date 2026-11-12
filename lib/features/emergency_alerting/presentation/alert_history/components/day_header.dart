import 'package:flutter/material.dart';

// The interface is in Spanish, so dates are too, whatever the phone's language
const _weekdays = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
const _months = ['ene.', 'feb.', 'mar.', 'abr.', 'may.', 'jun.', 'jul.', 'ago.', 'sept.', 'oct.', 'nov.', 'dic.'];

/// Section title of the history: "HOY", "AYER" or the date ("SÁBADO 26 SEPT.").
class DayHeader extends StatelessWidget {
  final DateTime day;
  final DateTime today;

  const new({super.key, required this.day, required this.today});

  @override
  Widget build(BuildContext context) {
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final label = switch (day) {
      _ when day == today => 'Hoy',
      _ when day == yesterday => 'Ayer',
      _ => '${_weekdays[day.weekday - 1]} ${day.day} ${_months[day.month - 1]}',
    };
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 2),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
