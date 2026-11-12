import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/vital_filter.dart';

/// "Todos los signos vitales ›": opens "Buscar y filtrar" and reads back what is applied.
class VitalSearchBar extends StatelessWidget {
  final VitalFilter filter;
  final VoidCallback onTap;

  const new({super.key, required this.filter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(GuardianRadius.medium);
    // Listed in the sheet's order, not in the order they were tapped
    final text = filter.isEmpty
        ? 'Todos los signos vitales'
        : VitalFilterOption.values.where(filter.options.contains).map((option) => option.label).join(' · ');

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: filter.isEmpty ? colors.outline : colors.primary),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                filter.isEmpty ? Icons.search : Icons.tune,
                size: 18,
                color: filter.isEmpty ? colors.onSurfaceVariant : colors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.onSurface),
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
