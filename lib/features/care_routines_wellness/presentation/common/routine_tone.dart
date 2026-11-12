import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';

/// Pastel tints of the routines prototype, shared by the category icons and their badges.
enum RoutineTone { mint, blue, violet, orange, yellow, muted, red }

/// Tints of the routines prototype that the Guardian+ theme does not carry.
abstract final class RoutineColors {
  // Yellow for what is coming next
  static const noticeContainer = Color(0xFFFFF4CC);
  static const onNoticeContainer = Color(0xFF806600);
  // Blue for appointments and hydration, violet for sleep
  static const infoContainer = Color(0xFFE1F4F7);
  static const onInfoContainer = Color(0xFF24798B);
  static const restContainer = Color(0xFFEBE8F8);
  static const onRestContainer = Color(0xFF5D4D8C);
}

/// Big numbers of the routine cards ("92%", "7 h 24 min"), in the data typeface.
const routineMetricStyle = TextStyle(
  fontFamily: GuardianFonts.data,
  fontWeight: FontWeight.w500,
  fontSize: 24,
  height: 26 / 24,
);

extension RoutineToneColors on RoutineTone {
  /// Container and content color of each tint.
  (Color, Color) colorsIn(ColorScheme scheme) {
    return switch (this) {
      RoutineTone.mint => (scheme.primaryContainer, scheme.primary),
      RoutineTone.blue => (RoutineColors.infoContainer, RoutineColors.onInfoContainer),
      RoutineTone.violet => (RoutineColors.restContainer, RoutineColors.onRestContainer),
      RoutineTone.orange => (scheme.tertiaryContainer, scheme.tertiary),
      RoutineTone.yellow => (RoutineColors.noticeContainer, RoutineColors.onNoticeContainer),
      RoutineTone.muted => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
      RoutineTone.red => (scheme.errorContainer, scheme.onErrorContainer),
    };
  }
}

/// Rounded badge of the prototype ("Tomada", "Stock bajo", "Fragmentado"…) in one of the tints.
class RoutineBadge extends StatelessWidget {
  final String text;
  final RoutineTone tone;

  const new({super.key, required this.text, this.tone = RoutineTone.mint});

  @override
  Widget build(BuildContext context) {
    final (container, content) = tone.colorsIn(Theme.of(context).colorScheme);
    return RoutineChip(text: text, container: container, content: content);
  }
}

/// Rounded label in any pair of colors, e.g. on the green status card of inactivity.
class RoutineChip extends StatelessWidget {
  final String text;
  final Color container;
  final Color content;

  const new({super.key, required this.text, required this.container, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: container, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: content)),
    );
  }
}
