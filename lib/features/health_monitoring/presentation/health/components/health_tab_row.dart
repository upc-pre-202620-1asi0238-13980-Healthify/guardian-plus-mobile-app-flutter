import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';

enum HealthTab {
  now('Ahora'),
  history('Historial');

  final String label;

  const HealthTab(this.label);
}

/// Segmented "Ahora · Historial" control of the prototype.
class HealthTabRow extends StatelessWidget {
  final HealthTab selectedTab;
  final ValueChanged<HealthTab> onTabSelected;

  const new({super.key, required this.selectedTab, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(GuardianRadius.medium);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: GuardianColors.neutralMuted, borderRadius: radius),
      child: Row(
        children: [
          for (final tab in HealthTab.values)
            Expanded(
              child: Material(
                color: tab == selectedTab ? colors.surface : GuardianColors.neutralMuted,
                elevation: tab == selectedTab ? 2 : 0,
                borderRadius: radius,
                child: InkWell(
                  onTap: () => onTabSelected(tab),
                  borderRadius: radius,
                  child: SizedBox(
                    height: 44,
                    child: Center(
                      child: Text(
                        tab.label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: tab == selectedTab ? colors.primary : colors.onSurfaceVariant,
                        ),
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
