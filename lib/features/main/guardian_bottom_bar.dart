import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/main/top_level_destination.dart';

/// Floating bottom navigation bar of the prototype: four regular tabs and the Alerts tab raised as a
/// round button in the middle, so the emergency entry point is recognizable by its shape.
class GuardianBottomBar extends StatelessWidget {
  final TopLevelDestination selected;
  final ValueChanged<TopLevelDestination> onDestinationTap;

  const new({super.key, required this.selected, required this.onDestinationTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(GuardianRadius.large);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: 74,
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: radius,
                border: Border.all(color: colors.outline),
                boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 12, offset: Offset(0, 4))],
              ),
              // Equal slots keep the Alerts label (the middle one) under the round button, whatever the
              // width of the other labels
              child: Row(
                children: [
                  for (final destination in TopLevelDestination.values)
                    Expanded(
                      child: _BottomBarItem(
                        destination: destination,
                        selected: destination == selected,
                        onTap: () => onDestinationTap(destination),
                      ),
                    ),
                ],
              ),
            ),
            _AlertsCenterButton(onTap: () => onDestinationTap(TopLevelDestination.alerts)),
          ],
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  final TopLevelDestination destination;
  final bool selected;
  final VoidCallback onTap;

  const new({required this.destination, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final contentColor = selected ? colors.primary : colors.onSurfaceVariant;
    final isAlerts = destination == TopLevelDestination.alerts;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GuardianRadius.medium),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // The Alerts icon is the raised round button; an empty slot keeps its label aligned with the others
          if (isAlerts)
            const SizedBox(height: 32)
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? colors.secondaryContainer : colors.surface,
                borderRadius: BorderRadius.circular(GuardianRadius.subtle),
              ),
              child: Icon(destination.icon, size: 20, color: contentColor),
            ),
          Text(
            destination.label,
            maxLines: 1,
            overflow: TextOverflow.visible,
            softWrap: false,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: contentColor),
          ),
        ],
      ),
    );
  }
}

class _AlertsCenterButton extends StatelessWidget {
  final VoidCallback onTap;

  const new({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Transform.translate(
      offset: const Offset(0, 2),
      child: Tooltip(
        message: TopLevelDestination.alerts.label,
        child: Material(
          color: colors.primary,
          shape: CircleBorder(side: BorderSide(color: colors.surface, width: 3)),
          elevation: 6,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox.square(
              dimension: 56,
              child: Icon(TopLevelDestination.alerts.icon, size: 24, color: colors.onPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
