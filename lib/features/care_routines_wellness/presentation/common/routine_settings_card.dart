import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';

/// Side padding that lines a select or a note up with the switch rows of a [RoutineSettingsCard].
const routineSettingsRowPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

/// Card of switches and selects; the rows bring their own 16 of side padding, as in the alert settings.
class RoutineSettingsCard extends StatelessWidget {
  final List<Widget> children;

  const new({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // A Material, not a decorated box: the switch rows paint their ink on it
    return Material(
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GuardianRadius.medium),
        side: BorderSide(color: colors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      ),
    );
  }
}

/// Setting with a switch. The whole row toggles it, so the touch target is not just the small switch.
class RoutineSwitchRow extends StatelessWidget {
  final String title;
  final String detail;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const new({
    super.key,
    required this.title,
    required this.detail,
    required this.value,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return SwitchListTile(
      value: value,
      onChanged: enabled ? onChanged : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(title, style: text.titleSmall?.copyWith(color: colors.onSurface)),
      subtitle: Text(detail, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
    );
  }
}
