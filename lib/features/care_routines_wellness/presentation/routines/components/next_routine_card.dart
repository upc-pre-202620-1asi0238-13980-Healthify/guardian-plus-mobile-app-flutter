import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_labels.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_tone.dart';

/// "14:00 · EN 25 MIN · Losartán 50 mg": the next pending routine of the day, tinted in pastel yellow.
class NextRoutineCard extends StatelessWidget {
  final Reminder reminder;
  final DateTime now;
  final VoidCallback onTap;

  const new({super.key, required this.reminder, required this.now, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final detail = reminder.detailLine;
    final radius = BorderRadius.circular(GuardianRadius.medium);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: colors.outline),
            // Yellow fading into white within the first third, as in the prototype
            gradient: LinearGradient(
              colors: [RoutineColors.noticeContainer, colors.surface],
              stops: const [0, 0.3],
            ),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatClockTime(reminder.scheduledTime),
                    style: dataLabelStyle.copyWith(color: RoutineColors.onNoticeContainer),
                  ),
                  Text(
                    timeUntil(reminder.scheduledTime, now),
                    style: dataLabelStyle.copyWith(color: RoutineColors.onNoticeContainer, fontSize: 9, height: 12 / 9),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: RoutineColors.noticeContainer, borderRadius: radius),
                child: Icon(reminder.type.icon, size: 20, color: RoutineColors.onNoticeContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reminder.displayTitle, style: text.titleSmall?.copyWith(color: colors.onSurface)),
                    if (detail.isNotEmpty)
                      Text(detail, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 18, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
