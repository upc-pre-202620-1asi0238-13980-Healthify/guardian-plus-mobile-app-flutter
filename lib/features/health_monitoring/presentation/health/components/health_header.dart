import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/reading_badge.dart';

/// Top bar of the Health section: who is being watched, whether the wearable is online and the overall state.
class HealthHeader extends StatelessWidget {
  final String userInitials;
  final String careRecipientName;
  final bool hasLiveSignal;
  final bool allWithinRange;
  final bool hasReadings;

  const new({
    super.key,
    required this.userInitials,
    required this.careRecipientName,
    required this.hasLiveSignal,
    required this.allWithinRange,
    required this.hasReadings,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return ColoredBox(
      color: colors.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(GuardianRadius.medium),
                  ),
                  child: Text(userInitials, style: text.titleMedium?.copyWith(color: colors.primary)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasLiveSignal ? '$careRecipientName · En línea' : '$careRecipientName · Sin señal',
                        style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                      ),
                      Text('Salud', style: text.titleLarge?.copyWith(color: colors.onSurface)),
                    ],
                  ),
                ),
                // Nothing to judge until the first readings arrive
                if (hasReadings) ReadingBadge(withinRange: allWithinRange),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
