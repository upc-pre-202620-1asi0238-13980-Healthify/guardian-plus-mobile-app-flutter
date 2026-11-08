import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';

/// Entry to the emergency contacts screen, with how many there are and who answers first.
class ContactsSummaryCard extends StatelessWidget {
  final int contactCount;
  final String? primaryContactName;
  final VoidCallback onTap;

  const new({super.key, required this.contactCount, required this.primaryContactName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final summary = switch ((contactCount, primaryContactName)) {
      (0, _) || (_, null) => 'Ningún contacto todavía',
      (1, final name?) => '1 contacto · $name',
      (final count, final name?) => '$count contactos · $name es el principal',
    };

    return Material(
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GuardianRadius.medium),
        side: BorderSide(color: colors.outline),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: colors.secondaryContainer,
          child: Icon(Icons.group_outlined, size: 22, color: colors.primary),
        ),
        title: Text('Contactos de emergencia', style: text.titleMedium?.copyWith(color: colors.onSurface)),
        subtitle: Text(summary, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
        trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
      ),
    );
  }
}
