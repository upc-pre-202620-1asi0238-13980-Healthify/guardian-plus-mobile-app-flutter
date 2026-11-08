import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/add_emergency_contact_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_settings_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_emergency_contacts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/remove_emergency_contact_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/reorder_emergency_contacts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/emergency_contacts/emergency_contacts_view_model.dart';

import '../fakes.dart';

void main() {
  late FakeEmergencyContactRepository contacts;
  late FakeAlertSettingsRepository settings;
  late CareContextStore store;

  EmergencyContactsViewModel createViewModel() {
    return EmergencyContactsViewModel(
      getEmergencyContacts: GetEmergencyContactsUseCase(repository: contacts),
      getAlertSettings: GetAlertSettingsUseCase(repository: settings),
      addEmergencyContact: AddEmergencyContactUseCase(repository: contacts),
      removeEmergencyContact: RemoveEmergencyContactUseCase(repository: contacts),
      reorderEmergencyContacts: ReorderEmergencyContactsUseCase(repository: contacts),
      careContextStore: store,
    );
  }

  setUp(() {
    contacts = FakeEmergencyContactRepository([
      contact('b', priorityOrder: 2),
      contact('a', priorityOrder: 1),
      contact('gone', priorityOrder: 3, active: false),
    ]);
    settings = FakeAlertSettingsRepository();
    store = careContextStore();
  });

  test('loads the active contacts in escalation order and the timeout', () async {
    final viewModel = createViewModel();
    await pumpEventQueue();

    expect(viewModel.state.contacts.map((contact) => contact.id), ['a', 'b']);
    expect(viewModel.state.ackTimeoutSec, 90);
    expect(viewModel.state.careRecipientFirstName, 'Elena');
    // The "call" buttons dial the primary contact
    expect(store.current!.callNumber, contacts.contacts[1].phoneNumber);
  });

  test('shows why the contacts could not be loaded', () async {
    contacts.failure = const ApiException('No se pudo conectar con el servidor. Revisa tu conexión.');
    final viewModel = createViewModel();
    await pumpEventQueue();

    expect(viewModel.state.isLoading, isFalse);
    expect(viewModel.state.errorMessage, 'No se pudo conectar con el servidor. Revisa tu conexión.');
  });

  test('moving a contact up sends the new chain and makes it the primary one', () async {
    final viewModel = createViewModel();
    await pumpEventQueue();

    await viewModel.move('b', -1);

    expect(contacts.reorders.single, ['b', 'a']);
    expect(viewModel.state.contacts.map((contact) => contact.id), ['b', 'a']);
    expect(viewModel.state.isSaving, isFalse);
  });

  test('a rejected reorder brings the previous order back and says why', () async {
    final viewModel = createViewModel();
    await pumpEventQueue();
    contacts.reorderFailure = const ApiException('El orden no es válido');

    await viewModel.move('b', -1);

    expect(viewModel.state.contacts.map((contact) => contact.id), ['a', 'b']);
    expect(viewModel.state.actionErrorMessage, 'El orden no es válido');
  });

  test('moving the primary contact up does nothing', () async {
    final viewModel = createViewModel();
    await pumpEventQueue();

    await viewModel.move('a', -1);

    expect(contacts.reorders, isEmpty);
  });

  test('removing a contact reads the renumbered chain again', () async {
    final viewModel = createViewModel();
    await pumpEventQueue();

    await viewModel.removeContact(viewModel.state.contacts.first);

    expect(viewModel.state.contacts.map((contact) => contact.id), ['b']);
    expect(viewModel.state.canRemove, isFalse);
    expect(store.current!.callNumber, viewModel.state.contacts.single.phoneNumber);
  });

  test('a new contact is trimmed, saved and added at the end', () async {
    final viewModel = createViewModel();
    await pumpEventQueue();

    final saved = await viewModel.addContact(
      displayName: '  Ana Torres ',
      relationship: 'Cuidadora ',
      phoneNumber: '+51987654323',
    );

    expect(saved, isTrue);
    expect(viewModel.state.contacts.last.displayName, 'Ana Torres');
    expect(viewModel.state.contacts.last.relationship, 'Cuidadora');
  });

  test('a rejected new contact keeps the sheet open with the reason', () async {
    final viewModel = createViewModel();
    await pumpEventQueue();
    contacts.failure = const ApiException('El teléfono ya está registrado');

    final saved = await viewModel.addContact(displayName: 'Ana', relationship: 'Hija', phoneNumber: '+51987654323');

    expect(saved, isFalse);
    expect(viewModel.state.addErrorMessage, 'El teléfono ya está registrado');
    viewModel.onAddSheetClosed();
    expect(viewModel.state.addErrorMessage, isNull);
  });

  test('a request that ends after the screen closed does not touch the disposed view model', () async {
    final viewModel = createViewModel();
    viewModel.dispose();

    await pumpEventQueue();
  });
}
