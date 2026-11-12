import 'package:flutter/material.dart';

/// Top bar of the screens opened from another one: back button, title, subtitle and an optional [trailing]
/// widget such as a state chip. [onBackPressed] is null when there is nowhere to go back to, and the button
/// is not drawn.
class DetailTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBackPressed;
  final Widget? trailing;

  const new({super.key, required this.title, required this.subtitle, this.onBackPressed, this.trailing});

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
                  if (onBackPressed != null) ...[
                    IconButton.outlined(
                      onPressed: onBackPressed,
                      tooltip: 'Volver',
                      icon: const Icon(Icons.chevron_left),
                      style: IconButton.styleFrom(side: BorderSide(color: colors.outline)),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // One line each: the bar has a fixed height
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
                  if (trailing != null) ...[const SizedBox(width: 8), trailing!],
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
