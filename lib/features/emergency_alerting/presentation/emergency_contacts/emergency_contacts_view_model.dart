import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/add_emergency_contact_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_settings_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_emergency_contacts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/remove_emergency_contact_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/reorder_emergency_contacts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/screen_states.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/emergency_contacts/emergency_contacts_state.dart';

/// The escalation chain of the person under care (US16): who receives the alerts and in which order.
class EmergencyContactsViewModel extends ChangeNotifier {
  final GetEmergencyContactsUseCase getEmergencyContacts;
  final GetAlertSettingsUseCase getAlertSettings;
  final AddEmergencyContactUseCase addEmergencyContact;
  final RemoveEmergencyContactUseCase removeEmergencyContact;
  final ReorderEmergencyContactsUseCase reorderEmergencyContacts;
  final CareContextStore careContextStore;

  new({
    required this.getEmergencyContacts,
    required this.getAlertSettings,
    required this.addEmergencyContact,
    required this.removeEmergencyContact,
    required this.reorderEmergencyContacts,
    required this.careContextStore,
  }) {
    loadContacts();
  }

  // Whose data this screen shows: the signed-in account and the person under its care
  late final CareContext _careContext = careContextStore.require();

  late EmergencyContactsState _state = EmergencyContactsState(careRecipientName: _careContext.careRecipientName);
  EmergencyContactsState get state => _state;

  bool _disposed = false;

  Future<void> loadContacts() async {
    _emit(_state.copyWith(isLoading: true, errorMessage: () => null));

    try {
      final settings = await getAlertSettings.execute(_careContext.careRecipientProfileId);
      _emit(_state.copyWith(ackTimeoutSec: settings.primaryAckTimeoutSec));
    } catch (_) {
      // Only the explanation text uses the timeout; the default reads fine
    }

    try {
      final contacts = await getEmergencyContacts.execute(_careContext.careRecipientProfileId);
      _emitContacts(_state.copyWith(isLoading: false, contacts: contacts.activeInOrder()));
    } catch (e) {
      _emit(_state.copyWith(
        isLoading: false,
        errorMessage: () => errorMessageOf(e, 'No se pudieron cargar los contactos'),
      ));
    }
  }

  /// Moves a contact one place up (-1) or down (+1) in the escalation chain.
  Future<void> move(String contactId, int offset) async {
    if (_state.isSaving) return;
    final previous = _state.contacts;
    final from = previous.indexWhere((contact) => contact.id == contactId);
    final to = from + offset;
    if (from == -1 || to < 0 || to >= previous.length) return;

    final reordered = [...previous];
    reordered.insert(to, reordered.removeAt(from));
    // The new order shows at once; if the platform rejects it, the previous one comes back
    _emit(_state.copyWith(contacts: reordered, isSaving: true));

    try {
      final saved = await reorderEmergencyContacts.execute(
        careRecipientProfileId: _careContext.careRecipientProfileId,
        orderedIds: reordered.map((contact) => contact.id).toList(),
      );
      _emitContacts(_state.copyWith(isSaving: false, contacts: saved.activeInOrder()));
    } catch (e) {
      _emit(_state.copyWith(
        isSaving: false,
        contacts: previous,
        actionErrorMessage: () => errorMessageOf(e, 'No se pudo cambiar el orden'),
      ));
    }
  }

  Future<void> removeContact(EmergencyContact contact) async {
    if (_state.isSaving) return;
    _emit(_state.copyWith(isSaving: true));
    try {
      await removeEmergencyContact.execute(contact.id);
      await _reloadAfterChange();
    } catch (e) {
      _emit(_state.copyWith(
        isSaving: false,
        actionErrorMessage: () => errorMessageOf(e, 'No se pudo eliminar el contacto'),
      ));
    }
  }

  /// Returns whether the contact was saved, so the sheet knows when to close.
  Future<bool> addContact({
    required String displayName,
    required String relationship,
    required String phoneNumber,
  }) async {
    if (_state.isAdding) return false;
    _emit(_state.copyWith(isAdding: true, addErrorMessage: () => null));
    try {
      await addEmergencyContact.execute(
        careRecipientProfileId: _careContext.careRecipientProfileId,
        displayName: displayName,
        relationship: relationship,
        phoneNumber: phoneNumber,
      );
      _emit(_state.copyWith(isAdding: false));
      await _reloadAfterChange();
      return true;
    } catch (e) {
      _emit(_state.copyWith(
        isAdding: false,
        addErrorMessage: () => errorMessageOf(e, 'No se pudo agregar el contacto'),
      ));
      return false;
    }
  }

  void onAddSheetClosed() {
    _emit(_state.copyWith(addErrorMessage: () => null));
  }

  void onActionErrorShown() {
    _emit(_state.copyWith(actionErrorMessage: () => null));
  }

  // Adding or removing changes the priorities of the others, so the list is read again
  Future<void> _reloadAfterChange() async {
    try {
      final contacts = await getEmergencyContacts.execute(_careContext.careRecipientProfileId);
      _emitContacts(_state.copyWith(isSaving: false, contacts: contacts.activeInOrder()));
    } catch (_) {
      _emit(_state.copyWith(isSaving: false));
    }
  }

  /// The "call" buttons dial the primary contact, so every change of the list updates that number.
  void _emitContacts(EmergencyContactsState state) {
    _emit(state);
    final contacts = state.contacts;
    careContextStore.updateCallNumber(contacts.isEmpty ? null : contacts.first.phoneNumber);
  }

  void _emit(EmergencyContactsState state) {
    // A request can finish after the user has left the screen
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
