import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/status_chip.dart';

/// Heart rate and SpO2 at the moment of the alert (Health Monitoring).
class VitalsRow extends StatelessWidget {
  final int? heartRateBpm;
  final int? oxygenSaturation;

  const new({super.key, required this.heartRateBpm, required this.oxygenSaturation});

  // Same ranges as the user stories of Health Monitoring (US01, US03)
  static const heartRateHigh = 100;
  static const heartRateLow = 60;
  static const oxygenLow = 92;

  @override
  Widget build(BuildContext context) {
    final heartRate = heartRateBpm;
    final oxygen = oxygenSaturation;
    final tiles = [
      if (heartRate != null)
        _VitalTile(
          label: 'Frecuencia cardíaca',
          value: '$heartRate',
          unit: 'lpm',
          reading: heartRate > heartRateHigh
              ? _Reading.high
              : heartRate < heartRateLow
              ? _Reading.low
              : _Reading.normal,
        ),
      if (oxygen != null)
        _VitalTile(
          label: 'Saturación O₂',
          value: '$oxygen',
          unit: '%',
          reading: oxygen < oxygenLow ? _Reading.low : _Reading.normal,
        ),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, tile) in tiles.indexed) ...[
          if (index > 0) const SizedBox(width: 12),
          Expanded(child: tile),
        ],
      ],
    );
  }
}

enum _Reading { normal, high, low }

class _VitalTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final _Reading reading;

  const new({required this.label, required this.value, required this.unit, required this.reading});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final (chipText, container, content) = switch (reading) {
      _Reading.high => ('Alta', scheme.tertiaryContainer, scheme.tertiary),
      _Reading.low => ('Baja', scheme.tertiaryContainer, scheme.tertiary),
      _Reading.normal => ('Normal', scheme.primaryContainer, scheme.onPrimaryContainer),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(GuardianRadius.medium),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: dataMetricStyle.copyWith(color: scheme.onSurface)),
              const SizedBox(width: 4),
              Text(unit, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          StatusChip(text: chipText, container: container, content: content),
        ],
      ),
    );
  }
}
