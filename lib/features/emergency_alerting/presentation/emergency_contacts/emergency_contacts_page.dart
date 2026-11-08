import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/detail_top_bar.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/screen_states.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/emergency_contacts/components/add_contact_sheet.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/emergency_contacts/components/contact_card.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/emergency_contacts/components/remove_contact_dialog.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/emergency_contacts/emergency_contacts_state.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/emergency_contacts/emergency_contacts_view_model.dart';

class EmergencyContactsPage extends StatefulWidget {
  final EmergencyContactsViewModel viewModel;

  const new({super.key, required this.viewModel});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  late final EmergencyContactsViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_showActionError);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_showActionError);
    // The page owns its view model: every visit starts with a fresh one (registerFactory)
    _viewModel.dispose();
    super.dispose();
  }

  // Rejections from the platform (e.g. removing the last contact) are shown once
  void _showActionError() {
    final message = _viewModel.state.actionErrorMessage;
    if (message == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    _viewModel.onActionErrorShown();
  }

  Future<void> _openAddSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddContactSheet(viewModel: _viewModel),
    );
    _viewModel.onAddSheetClosed();
  }

  Future<void> _confirmRemoval(EmergencyContact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => RemoveContactDialog(
        contactName: contact.displayName,
        careRecipientFirstName: _viewModel.state.careRecipientFirstName,
      ),
    );
    if (confirmed == true) _viewModel.removeContact(contact);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailTopBar(
        title: 'Contactos de emergencia',
        subtitle: _viewModel.state.careRecipientName,
        onBackPressed: Navigator.canPop(context) ? () => Navigator.pop(context) : null,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          final state = _viewModel.state;

          if (state.isLoading && state.contacts.isEmpty) {
            return const LoadingView();
          }
          if (state.errorMessage != null && state.contacts.isEmpty) {
            return ErrorRetryView(message: state.errorMessage!, onRetry: _viewModel.loadContacts);
          }
          return _ContactList(
            state: state,
            onMoveUp: (contact) => _viewModel.move(contact.id, -1),
            onMoveDown: (contact) => _viewModel.move(contact.id, 1),
            onRemove: _confirmRemoval,
            onAdd: _openAddSheet,
          );
        },
      ),
    );
  }
}

class _ContactList extends StatelessWidget {
  final EmergencyContactsState state;
  final ValueChanged<EmergencyContact> onMoveUp;
  final ValueChanged<EmergencyContact> onMoveDown;
  final ValueChanged<EmergencyContact> onRemove;
  final VoidCallback onAdd;

  const new({
    required this.state,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final contacts = state.contacts;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: BorderRadius.circular(GuardianRadius.medium),
          ),
          child: Text(
            contacts.isEmpty
                ? '${state.careRecipientFirstName} todavía no tiene contactos de emergencia. '
                      'Agrega al menos uno para que las alertas lleguen a alguien.'
                : 'Reciben las alertas de ${state.careRecipientFirstName} en este orden. Si el primero no '
                      'responde en ${state.ackTimeoutSec} s, se avisa a los siguientes.',
            style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
        for (final (index, contact) in contacts.indexed) ...[
          const SizedBox(height: 12),
          ContactCard(
            key: ValueKey(contact.id),
            contact: contact,
            position: index,
            isLast: index == contacts.length - 1,
            canRemove: state.canRemove,
            enabled: !state.isSaving,
            onMoveUp: () => onMoveUp(contact),
            onMoveDown: () => onMoveDown(contact),
            onRemove: () => onRemove(contact),
          ),
        ],
        if (contacts.length == 1) ...[
          const SizedBox(height: 12),
          Text(
            'Debe quedar al menos un contacto: es quien recibe las alertas primero.',
            style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: state.isSaving ? null : onAdd,
          icon: const Icon(Icons.person_add_alt_1, size: 18),
          label: const Text('Agregar contacto'),
        ),
      ],
    );
  }
}
