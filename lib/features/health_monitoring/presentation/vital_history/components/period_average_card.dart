import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_type.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/vital_filter.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/vital_signs_labels.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/vital_history/components/period_line_chart.dart';

/// "PROMEDIO SEMANAL 76.3 lpm · Mín 72 · Máx 80" and the chart of the selected vital sign.
class PeriodAverageCard extends StatelessWidget {
  final VitalSignType type;
  final HistoryPeriod period;
  final double? average;
  final double? min;
  final double? max;
  final List<double?> values;
  final List<DateTime> days;

  const new({
    super.key,
    required this.type,
    required this.period,
    required this.average,
    required this.min,
    required this.max,
    required this.values,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(GuardianRadius.large),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      period.averageLabel.toUpperCase(),
                      style: text.labelMedium?.copyWith(color: colors.onSurfaceVariant),
                    ),
                    if (average != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            // One decimal even for whole-number signs: 76.3 lpm says more than 76 over a period
                            Text(
                              average!.toStringAsFixed(1),
                              style: dataMetricStyle.copyWith(fontSize: 36, height: 40 / 36, color: colors.onSurface),
                            ),
                            Text(
                              ' ${type.displayUnit}',
                              style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(period.emptyLabel, style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
                      ),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  children: [
                    _MinMax(label: 'Mín', value: min != null ? type.format(min!) : null),
                    const VerticalDivider(width: 24),
                    _MinMax(label: 'Máx', value: max != null ? type.format(max!) : null),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          PeriodLineChart(values: values),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final label in _axisLabels(period, days))
                Text(label, style: dataLabelStyle.copyWith(color: colors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MinMax extends StatelessWidget {
  final String label;
  final String? value;

  const new({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(label, style: dataLabelStyle.copyWith(color: colors.onSurfaceVariant)),
        Text(value ?? '--', style: dataLabelStyle.copyWith(fontSize: 16, color: colors.onSurface)),
      ],
    );
  }
}

// Every day for a week; a few evenly spread marks for a day (hours) or a month (dates), or they would not fit
List<String> _axisLabels(HistoryPeriod period, List<DateTime> days) => switch (period) {
  HistoryPeriod.day => [for (final hour in [0, 6, 12, 18, 23]) '${hour}h'],
  HistoryPeriod.week => [for (final day in days) _weekdayLetter(day.weekday)],
  HistoryPeriod.month => [for (final index in [0, 7, 14, 22, days.length - 1]) '${days[index].day}'],
};

// Spanish weekday initials; Wednesday is "X" so it is not confused with Tuesday's "M"
String _weekdayLetter(int weekday) => const ['L', 'M', 'X', 'J', 'V', 'S', 'D'][weekday - 1];

extension on HistoryPeriod {
  String get averageLabel => switch (this) {
    HistoryPeriod.day => 'Promedio del día',
    HistoryPeriod.week => 'Promedio semanal',
    HistoryPeriod.month => 'Promedio mensual',
  };

  String get emptyLabel => switch (this) {
    HistoryPeriod.day => 'Sin lecturas hoy',
    HistoryPeriod.week => 'Sin lecturas esta semana',
    HistoryPeriod.month => 'Sin lecturas este mes',
  };
}
