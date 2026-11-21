import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/severity.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

/// "Todas · Críticas · Altas · Medias": the filters the platform supports (severity, not alert type).
class SeverityFilterRow extends StatelessWidget {
  final Severity? selected;
  final ValueChanged<Severity?> onSelected;

  const new({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final options = [
      (null, l10n.historyFilterAll),
      (Severity.critical, l10n.historyFilterCritical),
      (Severity.high, l10n.historyFilterHigh),
      (Severity.medium, l10n.historyFilterMedium),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (severity, label) in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label),
                selected: selected == severity,
                onSelected: (_) => onSelected(severity),
                showCheckmark: false,
                shape: const StadiumBorder(),
                selectedColor: scheme.primary,
                labelStyle: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(color: selected == severity ? scheme.onPrimary : scheme.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}
