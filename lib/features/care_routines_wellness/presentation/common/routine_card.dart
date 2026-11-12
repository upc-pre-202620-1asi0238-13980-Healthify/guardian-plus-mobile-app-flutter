import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';

/// White bordered card of the prototype with 15 of padding.
class RoutineCard extends StatelessWidget {
  final List<Widget> children;
  final Color? color;
  final Color? borderColor;

  const new({super.key, required this.children, this.color, this.borderColor});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        borderRadius: BorderRadius.circular(GuardianRadius.medium),
        border: Border.all(color: borderColor ?? colors.outline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

/// Title of a block of the screen ("Hoy", "Adherencia semanal"…) with an optional badge on the right.
class RoutineSectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  final double topPadding;

  const new({super.key, required this.text, this.trailing, this.topPadding = 10});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colors.onSurface)),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
