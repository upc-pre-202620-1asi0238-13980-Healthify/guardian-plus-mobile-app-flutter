import 'package:flutter/material.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

/// Confirmation before removing a contact: from then on they stop receiving the alerts.
/// Closes with true when the user confirms.
class RemoveContactDialog extends StatelessWidget {
  final String contactName;
  final String careRecipientFirstName;

  const new({super.key, required this.contactName, required this.careRecipientFirstName});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(context.l10n.removeContactTitle(contactName)),
      content: Text(
        context.l10n.removeContactMessage(careRecipientFirstName),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.commonCancel, style: TextStyle(color: colors.onSurfaceVariant)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.l10n.removeContactConfirm, style: TextStyle(color: colors.error)),
        ),
      ],
    );
  }
}
