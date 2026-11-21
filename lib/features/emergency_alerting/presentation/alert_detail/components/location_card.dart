import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

/// Where the person under care is (Mobility & Geofencing), with a shortcut to the map.
class LocationCard extends StatelessWidget {
  final String locationName;
  // "hace 30 s"; null when Mobility did not say when the position was taken
  final String? updatedAgo;
  final VoidCallback? onViewMap;

  const new({super.key, required this.locationName, required this.updatedAgo, this.onViewMap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(GuardianRadius.medium),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: scheme.secondaryContainer, shape: BoxShape.circle),
            child: Icon(Icons.location_on_outlined, size: 22, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(locationName, style: text.titleSmall?.copyWith(color: scheme.onSurface)),
                if (updatedAgo != null)
                  Text(
                    context.l10n.locationUpdated(updatedAgo!),
                    style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          if (onViewMap != null) TextButton(onPressed: onViewMap, child: Text(context.l10n.locationViewMap)),
        ],
      ),
    );
  }
}
