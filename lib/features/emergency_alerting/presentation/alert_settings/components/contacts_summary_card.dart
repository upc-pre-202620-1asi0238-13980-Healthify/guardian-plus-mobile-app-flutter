import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

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
    final l10n = context.l10n;
    final summary = switch ((contactCount, primaryContactName)) {
      (0, _) || (_, null) => l10n.contactsSummaryNone,
      (1, final name?) => l10n.contactsSummaryOne(name),
      (final count, final name?) => l10n.contactsSummaryMany(count, name),
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
        title: Text(l10n.emergencyContactsTitle, style: text.titleMedium?.copyWith(color: colors.onSurface)),
        subtitle: Text(summary, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
        trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
      ),
    );
  }
}
