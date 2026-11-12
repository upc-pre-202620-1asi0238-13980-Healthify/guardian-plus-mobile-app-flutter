import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_history/alert_history_state.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/alert_labels.dart';

/// Week at a glance: how many alerts, how fast the Care Circle answered and how many escalated.
class HistorySummaryCard extends StatelessWidget {
  final HistorySummary summary;

  const new({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final response = summary.averageResponseSec;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(GuardianRadius.medium),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          _Figure(value: '${summary.totalAlerts}', label: 'Alertas · 7 días', color: scheme.onSurface),
          _Figure(
            // Seconds read best in this narrow column ("81 s"); long waits fall back to minutes
            value: response == null ? '—' : (response < 600 ? '$response s' : formatDuration(response)),
            label: 'Respuesta media',
            color: scheme.primary,
          ),
          _Figure(
            value: '${summary.escalatedCount}',
            label: 'Escaladas',
            color: summary.escalatedCount > 0 ? scheme.error : scheme.onSurface,
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const new({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            style: dataMetricStyle.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
