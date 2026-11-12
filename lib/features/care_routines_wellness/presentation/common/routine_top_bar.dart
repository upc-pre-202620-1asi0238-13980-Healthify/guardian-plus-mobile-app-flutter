import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';

/// Top bar of every routine screen: back button, title, subtitle and an optional trailing element
/// (the "+" of Medicación and Citas, or the state badge of Sueño).
class RoutineTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBackPressed;
  final Widget? action;

  const new({super.key, required this.title, required this.subtitle, required this.onBackPressed, this.action});

  // Vertical padding (2 × 14) + back button touch target (48) + divider (1)
  @override
  Size get preferredSize => const Size.fromHeight(77);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: colors.surface,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  IconButton.outlined(
                    onPressed: onBackPressed,
                    tooltip: 'Volver',
                    icon: const Icon(Icons.chevron_left),
                    style: IconButton.styleFrom(side: BorderSide(color: colors.outline)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // One line each, so the bar keeps its height
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleLarge?.copyWith(color: colors.onSurface),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (action != null) ...[const SizedBox(width: 8), action!],
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}

/// Square mint button of the top bar, e.g. "+" to schedule a new dose or appointment.
class RoutineTopBarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const new({super.key, required this.icon, required this.tooltip, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton.filled(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.primary,
        fixedSize: const Size(44, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GuardianRadius.medium)),
      ),
    );
  }
}
