import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/phone_number.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/emergency_contacts/emergency_contacts_view_model.dart';

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
                Text('Nuevo contacto de emergencia', style: text.titleLarge?.copyWith(color: colors.onSurface)),
                const SizedBox(height: 4),
                Text(
                  'Se agregará al final de la lista de $careRecipientFirstName.',
                  style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nombre completo'),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [LengthLimitingTextInputFormatter(_maxNameLength)],
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'Escribe el nombre (máximo $_maxNameLength caracteres)'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _relationship,
                  decoration: const InputDecoration(labelText: 'Parentesco', hintText: 'Ej. Hija, vecino, cuidadora'),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [LengthLimitingTextInputFormatter(_maxRelationshipLength)],
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'Escribe el parentesco (máximo $_maxRelationshipLength caracteres)'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: 'Teléfono con código de país'),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[+0-9]'))],
                  validator: (value) => PhoneNumber.isValid((value ?? '').trim())
                      ? null
                      : 'Usa el formato internacional, por ejemplo +51987654321',
                  onFieldSubmitted: (_) => _save(),
                ),
                if (state.addErrorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(state.addErrorMessage!, style: text.bodySmall?.copyWith(color: colors.error)),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: state.isAdding ? null : _save,
                  icon: state.isAdding
                      ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.person_add_alt_1, size: 18),
                  label: const Text('Guardar contacto'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
