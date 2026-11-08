import 'package:flutter/material.dart';

/// Rounded label for a role or a state ("Principal", "En atención", "Notificada"…).
class StatusChip extends StatelessWidget {
  final String text;
  final Color container;
  final Color content;

  const new({super.key, required this.text, required this.container, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: container, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: content)),
    );
  }
}
