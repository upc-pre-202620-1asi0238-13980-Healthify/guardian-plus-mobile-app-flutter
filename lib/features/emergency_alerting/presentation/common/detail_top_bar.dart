import 'package:flutter/material.dart';

/// Top bar of the screens opened from another one: back button, title and subtitle.
/// [onBackPressed] is null when there is nowhere to go back to, and the button is not drawn.
class DetailTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBackPressed;

  const new({super.key, required this.title, required this.subtitle, this.onBackPressed});

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
                        Text(title, style: text.titleLarge?.copyWith(color: colors.onSurface)),
                        Text(subtitle, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                      ],
                    ),
                  ),
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
