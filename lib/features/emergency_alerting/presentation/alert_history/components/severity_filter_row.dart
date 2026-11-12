import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/severity.dart';

/// "Todas · Críticas · Altas · Medias": the filters the platform supports (severity, not alert type).
class SeverityFilterRow extends StatelessWidget {
  final Severity? selected;
  final ValueChanged<Severity?> onSelected;

  const new({super.key, required this.selected, required this.onSelected});

  static const _options = [
    (null, 'Todas'),
    (Severity.critical, 'Críticas'),
    (Severity.high, 'Altas'),
    (Severity.medium, 'Medias'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (severity, label) in _options)
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
