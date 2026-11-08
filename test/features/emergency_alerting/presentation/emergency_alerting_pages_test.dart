import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/add_emergency_contact_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/configure_alert_channel_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_channel_settings_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_settings_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_emergency_contacts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/remove_emergency_contact_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/reorder_emergency_contacts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/set_silent_mode_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/update_alert_settings_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_settings/alert_settings_page.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_settings/alert_settings_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/emergency_contacts/emergency_contacts_page.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/emergency_contacts/emergency_contacts_view_model.dart';

import '../fakes.dart';

void main() {
  late FakeEmergencyContactRepository contacts;
  late FakeAlertSettingsRepository settings;

  setUp(() {
    contacts = FakeEmergencyContactRepository([
      contact('a', priorityOrder: 1).withName('María Rojas'),
      contact('b', priorityOrder: 2).withName('Carlos Rojas'),
    ]);
    settings = FakeAlertSettingsRepository();
  });

  Widget app(Widget page) => MaterialApp(theme: GuardianTheme.light(), home: page);

  EmergencyContactsViewModel contactsViewModel() {
    return EmergencyContactsViewModel(
      getEmergencyContacts: GetEmergencyContactsUseCase(repository: contacts),
      getAlertSettings: GetAlertSettingsUseCase(repository: settings),
      addEmergencyContact: AddEmergencyContactUseCase(repository: contacts),
      removeEmergencyContact: RemoveEmergencyContactUseCase(repository: contacts),
      reorderEmergencyContacts: ReorderEmergencyContactsUseCase(repository: contacts),
      careContextStore: careContextStore(),
    );
  }

  testWidgets('the contacts screen lists the chain and removes a contact after confirming', (tester) async {
    await tester.pumpWidget(app(EmergencyContactsPage(viewModel: contactsViewModel())));
    await tester.pumpAndSettle();

    expect(find.text('Principal'), findsOneWidget);
    expect(find.text('Secundario 1'), findsOneWidget);
    expect(find.textContaining('Si el primero no responde en 90 s'), findsOneWidget);

    await tester.tap(find.byTooltip('Eliminar a Carlos Rojas'));
    await tester.pumpAndSettle();
    expect(find.text('¿Eliminar a Carlos Rojas?'), findsOneWidget);

    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(find.text('Carlos Rojas'), findsNothing);
    expect(find.text('Debe quedar al menos un contacto: es quien recibe las alertas primero.'), findsOneWidget);
  });

  testWidgets('the new-contact form checks the phone before sending', (tester) async {
    await tester.pumpWidget(app(EmergencyContactsPage(viewModel: contactsViewModel())));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Agregar contacto'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre completo'), 'Ana Torres');
    await tester.enterText(find.widgetWithText(TextFormField, 'Parentesco'), 'Cuidadora');
    await tester.enterText(find.widgetWithText(TextFormField, 'Teléfono con código de país'), '987');
    await tester.tap(find.text('Guardar contacto'));
    await tester.pumpAndSettle();

    expect(find.text('Usa el formato internacional, por ejemplo +51987654321'), findsOneWidget);
    expect(contacts.contacts, hasLength(2));

    await tester.enterText(find.widgetWithText(TextFormField, 'Teléfono con código de país'), '+51987654323');
    await tester.tap(find.text('Guardar contacto'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo contacto de emergencia'), findsNothing);
    expect(find.text('Ana Torres'), findsOneWidget);
  });

  testWidgets('the settings screen shows the summary and the saved values', (tester) async {
    final viewModel = AlertSettingsViewModel(
      getAlertSettings: GetAlertSettingsUseCase(repository: settings),
      updateAlertSettings: UpdateAlertSettingsUseCase(repository: settings),
      setSilentMode: SetSilentModeUseCase(repository: settings),
      getAlertChannelSettings: GetAlertChannelSettingsUseCase(repository: FakeAlertChannelSettingRepository()),
      configureAlertChannel: ConfigureAlertChannelUseCase(repository: FakeAlertChannelSettingRepository()),
      getEmergencyContacts: GetEmergencyContactsUseCase(repository: contacts),
      careContextStore: careContextStore(),
    );

    await tester.pumpWidget(app(AlertSettingsPage(viewModel: viewModel)));
    await tester.pumpAndSettle();

    expect(find.text('2 contactos · María Rojas es el principal'), findsOneWidget);
    final selected = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '90 s'));
    expect(selected.selected, isTrue);

    await tester.tap(find.text('120 s'));
    await tester.pumpAndSettle();

    expect(settings.settings.primaryAckTimeoutSec, 120);
  });
}
