import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';

/// Static, as in the Kotlin app: next medication and today's routine progress of the prototype.
class UpcomingCard extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(GuardianRadius.large),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: GuardianColors.noticeContainer,
                    borderRadius: BorderRadius.circular(GuardianRadius.medium),
                  ),
                  child: const Icon(Icons.medication_outlined, size: 22, color: GuardianColors.onNoticeContainer),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '14:00 · EN 25 MIN',
                        style: dataLabelStyle.copyWith(color: GuardianColors.onNoticeContainer),
                      ),
                      Text('Losartán 50 mg', style: text.titleSmall?.copyWith(color: colors.onSurface)),
                      Text(
                        '1 tableta · Después del almuerzo',
                        style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: colors.onSurfaceVariant),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(GuardianRadius.subtle),
                  ),
                  child: Icon(Icons.check, size: 16, color: colors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    '3 de 4 rutinas completadas',
                    style: text.bodyMedium?.copyWith(color: colors.onSurface),
                  ),
                ),
                Text('75%', style: dataLabelStyle.copyWith(color: colors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
