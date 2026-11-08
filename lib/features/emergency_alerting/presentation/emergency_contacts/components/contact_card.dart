import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/text/initials.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/status_chip.dart';

/// One contact of the escalation chain with its place in it. Arrows reorder the chain (US16) and the trash
/// button removes the contact; both are disabled while a change is being saved.
class ContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final int position;
  final bool isLast;
  final bool canRemove;
  final bool enabled;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onRemove;

  const new({
    super.key,
    required this.contact,
    required this.position,
    required this.isLast,
    required this.canRemove,
    required this.enabled,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isPrimary = position == 0;

    return Container(
      padding: const EdgeInsets.only(left: 16, top: 12, bottom: 12, right: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(GuardianRadius.medium),
        border: Border.all(color: isPrimary ? colors.primary : colors.outline),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isPrimary ? colors.primaryContainer : colors.surfaceContainerHighest,
            child: Text(
              initialsOf(contact.displayName),
              style: text.titleSmall?.copyWith(color: isPrimary ? colors.primary : colors.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusChip(
                  text: isPrimary ? 'Principal' : 'Secundario $position',
                  container: isPrimary ? colors.primaryContainer : colors.surfaceContainerHighest,
                  content: isPrimary ? colors.onPrimaryContainer : colors.onSurfaceVariant,
                ),
                const SizedBox(height: 6),
                Text(contact.displayName, style: text.titleMedium?.copyWith(color: colors.onSurface)),
                Text(contact.relationship, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                Text(contact.phoneNumber, style: dataLabelStyle.copyWith(color: colors.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: enabled && !isPrimary ? onMoveUp : null,
                tooltip: 'Subir a ${contact.displayName}',
                color: colors.primary,
                icon: const Icon(Icons.keyboard_arrow_up),
              ),
              IconButton(
                onPressed: enabled && !isLast ? onMoveDown : null,
                tooltip: 'Bajar a ${contact.displayName}',
                color: colors.primary,
                icon: const Icon(Icons.keyboard_arrow_down),
              ),
            ],
          ),
          IconButton(
            onPressed: enabled && canRemove ? onRemove : null,
            tooltip: 'Eliminar a ${contact.displayName}',
            color: colors.error,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}
