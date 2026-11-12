import 'package:flutter/material.dart';

/// Rounded label for a role or a state ("Principal", "En atención", "Notificada"…), optionally with a check mark.
class StatusChip extends StatelessWidget {
  final String text;
  final Color container;
  final Color content;
  final bool showCheck;

  const new({
    super.key,
    required this.text,
    required this.container,
    required this.content,
    this.showCheck = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: container, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showCheck) ...[Icon(Icons.check, size: 12, color: content), const SizedBox(width: 4)],
          Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: content)),
        ],
      ),
    );
  }
}
