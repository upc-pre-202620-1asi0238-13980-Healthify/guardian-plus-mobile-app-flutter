import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/reading_badge.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/live_vitals/components/sparkline.dart';

/// Green card that leads "Ahora": the heart rate, its line of the day and the wristband that measures it.
class HeartRateHeroCard extends StatelessWidget {
  final String title;
  final String valueText;
  final String unit;
  final bool withinRange;
  final String timeText;
  final String caption;
  final List<double> sparkline;
  final String wristbandText;
  final String? maxMinText;

  const new({
    super.key,
    required this.title,
    required this.valueText,
    required this.unit,
    required this.withinRange,
    required this.timeText,
    required this.caption,
    required this.sparkline,
    required this.wristbandText,
    required this.maxMinText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final onCard = colors.onPrimary;

    return Container(
      decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(GuardianRadius.large)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.toUpperCase(),
                            style: text.labelSmall?.copyWith(letterSpacing: 1, color: onCard.withValues(alpha: 0.8)),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(valueText, style: dataMetricStyle.copyWith(fontSize: 56, height: 64 / 56, color: onCard)),
                              Text(' $unit', style: text.bodyLarge?.copyWith(color: onCard.withValues(alpha: 0.75))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ReadingBadge(withinRange: withinRange),
                        const SizedBox(height: 10),
                        Text(timeText, style: dataLabelStyle.copyWith(color: onCard.withValues(alpha: 0.6))),
                      ],
                    ),
                  ],
                ),
                Text(caption, style: text.bodySmall?.copyWith(color: onCard.withValues(alpha: 0.75))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: SizedBox(
              height: 48,
              width: double.infinity,
              child: Sparkline(
                values: sparkline,
                lineColor: onCard.withValues(alpha: 0.7),
                fillColor: onCard.withValues(alpha: 0.18),
              ),
            ),
          ),
          Divider(height: 1, color: onCard.withValues(alpha: 0.15)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.watch_outlined, size: 16, color: onCard.withValues(alpha: 0.75)),
                const SizedBox(width: 8),
                Text(wristbandText, style: text.bodySmall?.copyWith(color: onCard.withValues(alpha: 0.75))),
                const Spacer(),
                if (maxMinText != null)
                  Text(maxMinText!, style: dataLabelStyle.copyWith(color: onCard.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
