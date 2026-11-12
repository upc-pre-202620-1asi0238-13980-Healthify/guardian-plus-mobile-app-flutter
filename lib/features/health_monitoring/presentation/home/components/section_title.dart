import 'package:flutter/material.dart';

/// "Signos vitales ······ Ver detalle": section heading with its link on the right.
class SectionTitle extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onActionTap;

  const new({super.key, required this.title, required this.action, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: text.titleLarge?.copyWith(color: colors.onSurface))),
          TextButton(
            onPressed: onActionTap,
            child: Text(action, style: text.labelLarge?.copyWith(color: colors.primary)),
          ),
        ],
      ),
    );
  }
}
