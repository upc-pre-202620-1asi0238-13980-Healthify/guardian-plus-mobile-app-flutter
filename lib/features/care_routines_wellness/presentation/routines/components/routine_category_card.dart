import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_tone.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/routines/routine_category.dart';

/// One row of "Todas las rutinas": tinted icon, name, today's summary and an optional badge.
class RoutineCategoryCard extends StatelessWidget {
  final RoutineCategory category;
  final RoutineCategorySummary summary;
  final VoidCallback onTap;

  const new({super.key, required this.category, required this.summary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final (iconContainer, iconContent) = category.tone.colorsIn(colors);
    final radius = BorderRadius.circular(GuardianRadius.medium);

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: colors.outline)),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: iconContainer, borderRadius: radius),
                child: Icon(category.icon, size: 20, color: iconContent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(category.title, style: text.titleSmall?.copyWith(color: colors.onSurface)),
                        ),
                        if (summary.badge != null) ...[
                          const SizedBox(width: 8),
                          RoutineBadge(text: summary.badge!, tone: summary.badgeTone),
                        ],
                      ],
                    ),
                    Text(summary.detail, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
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
