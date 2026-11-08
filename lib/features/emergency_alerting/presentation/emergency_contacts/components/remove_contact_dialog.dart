import 'package:flutter/material.dart';

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
      title: Text('¿Eliminar a $contactName?'),
      content: Text(
        'Dejará de recibir las alertas de $careRecipientFirstName. El resto de la lista sube un lugar.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancelar', style: TextStyle(color: colors.onSurfaceVariant)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Eliminar', style: TextStyle(color: colors.error)),
        ),
      ],
    );
  }
}
