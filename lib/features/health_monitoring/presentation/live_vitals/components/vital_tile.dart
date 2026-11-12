import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/reading_badge.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/live_vitals/components/range_bar.dart';

/// One cell of the "Ahora" grid: the latest value, where it sits in its normal range and how it is moving.
class VitalTile extends StatelessWidget {
  final String title;
  final String? valueText;
  final String unit;
  final bool withinRange;
  final RangeMarker? marker;
  final String? caption;

  const new({
    super.key,
    required this.title,
    required this.valueText,
    required this.unit,
    required this.withinRange,
    required this.marker,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(GuardianRadius.large),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    title.toUpperCase(),
                    style: text.labelSmall?.copyWith(letterSpacing: 1, color: colors.onSurfaceVariant),
                  ),
                ),
              ),
              if (valueText != null) ...[const SizedBox(width: 6), ReadingBadge(withinRange: withinRange)],
            ],
          ),
          const Spacer(),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                valueText ?? '--',
                maxLines: 1,
                softWrap: false,
                style: dataMetricStyle.copyWith(
                  fontSize: 26,
                  height: 30 / 26,
                  color: withinRange ? colors.onSurface : colors.tertiary,
                ),
              ),
              Flexible(
                child: Text(
                  ' $unit',
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          if (marker != null) ...[const SizedBox(height: 12), RangeBar(marker: marker!, withinRange: withinRange)],
          if (caption != null) ...[
            const SizedBox(height: 10),
            Text(caption!, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}
