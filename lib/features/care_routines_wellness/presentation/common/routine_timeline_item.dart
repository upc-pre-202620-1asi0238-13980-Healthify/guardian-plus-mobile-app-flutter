import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_tone.dart';

/// Where a routine of the day stands, which sets the colors of its dot and border.
enum TimelineState { done, current, upcoming, missed }

/// One block of "Hoy" or "Plan de hoy": time, state dot, title, detail and badge. The current block may carry
/// an action ("Confirmar toma", "Registrar como completada") across the whole card.
class RoutineTimelineItem extends StatelessWidget {
  final String time;
  final IconData icon;
  final String title;
  final String detail;
  final String badge;
  final RoutineTone badgeTone;
  final TimelineState state;
  final String? actionLabel;
  final IconData actionIcon;
  final bool isActionLoading;
  final VoidCallback? onAction;

  const new({
    super.key,
    required this.time,
    required this.icon,
    required this.title,
    required this.detail,
    required this.badge,
    required this.badgeTone,
    required this.state,
    this.actionLabel,
    this.actionIcon = Icons.check,
    this.isActionLoading = false,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final (dotContainer, dotContent) = switch (state) {
      TimelineState.done => (colors.primaryContainer, colors.primary),
      TimelineState.current => (RoutineColors.noticeContainer, RoutineColors.onNoticeContainer),
      TimelineState.upcoming => (colors.surfaceContainerHighest, colors.onSurfaceVariant),
      TimelineState.missed => (colors.tertiaryContainer, colors.tertiary),
    };
    final border = state == TimelineState.current
        ? RoutineColors.onNoticeContainer.withValues(alpha: 0.35)
        : colors.outline;
    final dotIcon = switch (state) {
      TimelineState.done => Icons.check,
      TimelineState.missed => Icons.close,
      TimelineState.upcoming => Icons.schedule,
      TimelineState.current => icon,
    };

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(GuardianRadius.medium),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 48,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(time, style: dataLabelStyle.copyWith(color: colors.onSurface)),
                ),
              ),
              CircleAvatar(
                radius: 14,
                backgroundColor: dotContainer,
                child: Icon(dotIcon, size: 15, color: dotContent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleSmall?.copyWith(color: colors.onSurface)),
                    if (detail.isNotEmpty)
                      Text(detail, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              RoutineBadge(text: badge, tone: badgeTone),
            ],
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: isActionLoading ? null : onAction,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44), shape: const StadiumBorder()),
              child: isActionLoading
                  ? SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(actionIcon, size: 18), const SizedBox(width: 7), Text(actionLabel!)],
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
