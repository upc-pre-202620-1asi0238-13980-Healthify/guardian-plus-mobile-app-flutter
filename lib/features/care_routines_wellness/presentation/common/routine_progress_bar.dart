import 'package:flutter/material.dart';

/// Thin rounded bar with an optional "Adherencia diaria · 67%" line above it.
class RoutineProgressBar extends StatelessWidget {
  final int percentage;
  final String? label;
  final bool? showPercentage;
  final Color? track;
  final Color? progress;
  final Color? textColor;

  const new({
    super.key,
    required this.percentage,
    this.label,
    this.showPercentage,
    this.track,
    this.progress,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final withPercentage = showPercentage ?? label != null;
    final labelColor = textColor ?? colors.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null || withPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              children: [
                Expanded(child: Text(label ?? '', style: text.labelMedium?.copyWith(color: labelColor))),
                if (withPercentage)
                  Text('$percentage%', style: text.labelMedium?.copyWith(color: labelColor, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: track ?? colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(3),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: percentage.clamp(0, 100) / 100,
            heightFactor: 1,
            child: Container(
              decoration: BoxDecoration(
                color: progress ?? colors.secondary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
