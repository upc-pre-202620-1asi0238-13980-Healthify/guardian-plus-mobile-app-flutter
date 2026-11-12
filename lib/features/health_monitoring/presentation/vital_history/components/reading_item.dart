import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_labels.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_reading.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_type.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/reading_badge.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/vital_signs_labels.dart';

/// "Hoy · 14:32 · Ritmo cardíaco · 78 lpm · Normal": one past reading.
class ReadingItem extends StatelessWidget {
  final VitalSignReading reading;
  final VitalSignReading? diastolic;
  final bool withinRange;
  final DateTime today;

  const new({
    super.key,
    required this.reading,
    required this.diastolic,
    required this.withinRange,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final day = DateUtils.dateOnly(reading.measuredAt.toLocal());
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final dayText = day == today
        ? 'Hoy'
        : day == yesterday
        ? 'Ayer'
        : '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}';
    final type = reading.type;
    final valueText = type == VitalSignType.bpSys && diastolic != null
        ? '${type.format(reading.value)}/${type.format(diastolic!.value)} ${type.displayUnit}'
        : '${type.format(reading.value)} ${type.displayUnit}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(GuardianRadius.large),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$dayText · ${formatClockTime(reading.measuredAt)}',
                  style: dataLabelStyle.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(type.label, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: colors.onSurface)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(valueText, style: dataLabelStyle.copyWith(fontSize: 16, color: colors.onSurface)),
          ),
          ReadingBadge(withinRange: withinRange),
        ],
      ),
    );
  }
}
