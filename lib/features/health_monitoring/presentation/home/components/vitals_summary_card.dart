import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_labels.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/live_vital_sign.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/live_vital_signs.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_type.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/reading_badge.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/vital_signs_labels.dart';

// The live endpoint returns one value per type, not a series, so the bars next to the heart rate are decorative
const _decorativeBarHeights = [14.0, 20.0, 12.0, 24.0, 18.0, 30.0, 16.0, 22.0, 26.0, 18.0];

/// Heart rate in large type and the other four readings in a 2×2 grid.
class VitalsSummaryCard extends StatelessWidget {
  final LiveVitalSigns vitals;
  final String? bloodPressureText;
  final bool bloodPressureOutOfRange;
  final DateTime now;

  const new({
    super.key,
    required this.vitals,
    required this.bloodPressureText,
    required this.bloodPressureOutOfRange,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const divider = VerticalDivider(width: 1);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(GuardianRadius.large),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        children: [
          _HeartRateBlock(heartRate: vitals[VitalSignType.hr], now: now),
          const Divider(height: 1),
          IntrinsicHeight(
            child: Row(
              children: [
                _VitalCell(
                  type: VitalSignType.bpSys,
                  valueText: bloodPressureText,
                  outOfRange: bloodPressureOutOfRange,
                ),
                divider,
                _VitalCell.of(vitals[VitalSignType.spo2], VitalSignType.spo2),
              ],
            ),
          ),
          const Divider(height: 1),
          IntrinsicHeight(
            child: Row(
              children: [
                _VitalCell.of(vitals[VitalSignType.temp], VitalSignType.temp),
                divider,
                _VitalCell.of(vitals[VitalSignType.respRate], VitalSignType.respRate),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartRateBlock extends StatelessWidget {
  final LiveVitalSign? heartRate;
  final DateTime now;

  const new({required this.heartRate, required this.now});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final reading = heartRate;
    final outOfRange = reading?.classification.isOutRange == true;
    const type = VitalSignType.hr;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(GuardianRadius.medium),
                ),
                child: Icon(type.icon, size: 24, color: colors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type.label, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          reading != null ? type.format(reading.value) : '--',
                          style: dataMetricStyle.copyWith(
                            fontSize: 36,
                            height: 40 / 36,
                            color: outOfRange ? colors.tertiary : colors.onSurface,
                          ),
                        ),
                        Text(' ${type.displayUnit}', style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final (index, height) in _decorativeBarHeights.indexed) ...[
                    if (index > 0) const SizedBox(width: 4),
                    Container(
                      width: 4,
                      height: height,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (reading != null) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1)),
            Row(
              children: [
                ReadingBadge(withinRange: !outOfRange, long: true),
                const Spacer(),
                Text(
                  relativeTime(reading.measuredAt, now),
                  style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _VitalCell extends StatelessWidget {
  final VitalSignType type;
  final String? valueText;
  final bool outOfRange;

  const new({required this.type, required this.valueText, required this.outOfRange});

  _VitalCell.of(LiveVitalSign? reading, this.type)
    : valueText = reading != null ? type.format(reading.value) : null,
      outOfRange = reading?.classification.isOutRange == true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(type.icon, size: 14, color: colors.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(type.label, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  valueText ?? '--',
                  style: dataMetricStyle.copyWith(color: outOfRange ? colors.tertiary : colors.onSurface),
                ),
                Text(' ${type.displayUnit}', style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
