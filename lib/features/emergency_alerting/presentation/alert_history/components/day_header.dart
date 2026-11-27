import 'package:flutter/material.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

/// Section title of the history: "HOY", "AYER" or the date ("SÁBADO 26 SEPT.").
class DayHeader extends StatelessWidget {
  final DateTime day;
  final DateTime today;

  const new({super.key, required this.day, required this.today});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    // Names come from the app's language, not the phone's, like the rest of the interface
    final label = switch (day) {
      _ when day == today => l10n.historyToday,
      _ when day == yesterday => l10n.historyYesterday,
      _ => l10n.historyDay(l10n.historyWeekday('${day.weekday}'), day.day, l10n.historyMonth('${day.month}')),
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
