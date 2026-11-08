import 'package:flutter/material.dart';

/// Setting with a switch. The whole row toggles it, so the touch target is not just the small switch.
class SettingSwitchRow extends StatelessWidget {
  final String title;
  final String? detail;
  final IconData? icon;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const new({
    super.key,
    required this.title,
    this.detail,
    this.icon,
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
      secondary: icon == null
          ? null
          : CircleAvatar(
              radius: 20,
              backgroundColor: colors.secondaryContainer,
              child: Icon(icon, size: 20, color: colors.primary),
            ),
      title: Text(title, style: text.titleSmall?.copyWith(color: colors.onSurface)),
      subtitle: detail == null
          ? null
          : Text(detail!, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
    );
  }
}
