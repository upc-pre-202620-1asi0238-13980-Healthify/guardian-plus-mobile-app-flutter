import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';

enum AlertsTab { active, history }

/// Segmented "Activas · Historial" control of the prototype.
class AlertsTabBar extends StatelessWidget {
  final AlertsTab selected;
  final ValueChanged<AlertsTab> onSelected;

  const new({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(GuardianRadius.medium),
      ),
      child: Row(
        children: [
          for (final tab in AlertsTab.values)
            Expanded(
              child: Material(
                color: tab == selected ? scheme.surface : Colors.transparent,
                elevation: tab == selected ? 1 : 0,
                borderRadius: BorderRadius.circular(GuardianRadius.medium),
                child: InkWell(
                  onTap: () => onSelected(tab),
                  borderRadius: BorderRadius.circular(GuardianRadius.medium),
                  child: SizedBox(
                    height: 44,
                    child: Center(
                      child: Text(
                        tab == AlertsTab.active ? 'Activas' : 'Historial',
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(color: tab == selected ? scheme.primary : scheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
