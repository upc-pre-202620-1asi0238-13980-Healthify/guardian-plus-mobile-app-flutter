import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';

/// White card with a border: the container of every section of the alert detail.
class DetailCard extends StatelessWidget {
  final List<Widget> children;

  const new({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(GuardianRadius.medium),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}
