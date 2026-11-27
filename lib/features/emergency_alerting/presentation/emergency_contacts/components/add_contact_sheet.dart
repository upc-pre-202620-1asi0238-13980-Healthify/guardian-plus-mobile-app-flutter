import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/phone_number.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/emergency_contacts/emergency_contacts_view_model.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

// Same limits as the platform's AddEmergencyContactResource
const _maxNameLength = 100;
const _maxRelationshipLength = 50;
const _defaultCountryCode = '+51';

/// Bottom sheet with the new-contact form (US16). Fields are checked here with the platform's rules before
/// sending, and the sheet closes once the contact is saved.
class AddContactSheet extends StatefulWidget {
  final EmergencyContactsViewModel viewModel;

  const new({super.key, required this.viewModel});

  @override
  State<AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<AddContactSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _relationship = TextEditingController();
  final _phone = TextEditingController(text: _defaultCountryCode);
  // Errors only show after the first attempt, so an empty form does not start in red
  var _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _name.dispose();
    _relationship.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
    if (!_formKey.currentState!.validate()) return;

    final saved = await widget.viewModel.addContact(
      displayName: _name.text,
      relationship: _relationship.text,
      phoneNumber: _phone.text,
    );
    if (saved && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final careRecipientFirstName = widget.viewModel.state.careRecipientFirstName;
    final l10n = context.l10n;

    return Padding(
      // Keeps the form above the keyboard
      padding: EdgeInsets.only(left: 20, right: 20, bottom: MediaQuery.viewInsetsOf(context).bottom + 16),
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, child) {
            final state = widget.viewModel.state;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.addContactTitle, style: text.titleLarge?.copyWith(color: colors.onSurface)),
                const SizedBox(height: 4),
                Text(
                  l10n.addContactSubtitle(careRecipientFirstName),
                  style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(labelText: l10n.addContactName),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [LengthLimitingTextInputFormatter(_maxNameLength)],
                  validator: (value) => (value ?? '').trim().isEmpty ? l10n.addContactNameError(_maxNameLength) : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _relationship,
                  decoration: InputDecoration(
                    labelText: l10n.addContactRelationship,
                    hintText: l10n.addContactRelationshipHint,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [LengthLimitingTextInputFormatter(_maxRelationshipLength)],
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? l10n.addContactRelationshipError(_maxRelationshipLength) : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  decoration: InputDecoration(labelText: l10n.addContactPhone),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[+0-9]'))],
                  validator: (value) => PhoneNumber.isValid((value ?? '').trim()) ? null : l10n.addContactPhoneError,
                  onFieldSubmitted: (_) => _save(),
                ),
                if (state.addError != null) ...[
                  const SizedBox(height: 12),
                  Text(state.addError!.message(l10n), style: text.bodySmall?.copyWith(color: colors.error)),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: state.isAdding ? null : _save,
                  icon: state.isAdding
                      ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.person_add_alt_1, size: 18),
                  label: Text(l10n.addContactSave),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
