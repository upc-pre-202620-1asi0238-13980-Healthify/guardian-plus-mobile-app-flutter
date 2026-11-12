import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_tone.dart';

/// Colored notice of the prototype: yellow for what is coming, orange for what needs attention, mint for info.
class RoutineBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final RoutineTone tone;
  final String? actionLabel;
  final bool isActionLoading;
  final VoidCallback? onAction;

  const new({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.tone,
    this.actionLabel,
    this.isActionLoading = false,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final (container, content) = tone.colorsIn(colors);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: container,
        borderRadius: BorderRadius.circular(GuardianRadius.medium),
        border: Border.all(color: content.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 20, color: content)),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall?.copyWith(color: content)),
                Text(message, style: text.bodySmall?.copyWith(color: content.withValues(alpha: 0.82))),
              ],
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 11),
            Align(
              alignment: Alignment.center,
              child: OutlinedButton(
                onPressed: isActionLoading ? null : onAction,
                style: OutlinedButton.styleFrom(
                  backgroundColor: colors.surface,
                  side: BorderSide(color: colors.primary),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 34),
                ),
                child: isActionLoading
                    ? const SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(actionLabel!, style: text.labelMedium),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Muted one-line note with an icon, e.g. how the stock balance is calculated.
class RoutineInfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const new({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(GuardianRadius.subtle),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
