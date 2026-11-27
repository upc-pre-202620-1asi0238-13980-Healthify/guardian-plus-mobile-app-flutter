import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

const _maxNotesLength = 2000;

/// Confirmation for stabilizing or closing an incident, with optional notes that the platform stores on it.
/// Closes with the notes when the user confirms, or with null when they cancel.
class NotesDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmLabel;

  const new({super.key, required this.title, required this.message, required this.confirmLabel});

  @override
  State<NotesDialog> createState() => _NotesDialogState();
}

class _NotesDialogState extends State<NotesDialog> {
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          TextField(
            controller: _notes,
            minLines: 3,
            maxLines: 5,
            inputFormatters: [LengthLimitingTextInputFormatter(_maxNotesLength)],
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: context.l10n.notesLabel,
              hintText: context.l10n.notesHint,
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonCancel, style: TextStyle(color: scheme.onSurfaceVariant)),
        ),
        TextButton(onPressed: () => Navigator.pop(context, _notes.text.trim()), child: Text(widget.confirmLabel)),
      ],
    );
  }
}
