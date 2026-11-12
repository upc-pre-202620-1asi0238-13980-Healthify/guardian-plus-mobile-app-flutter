import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/acknowledge_alert_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/claim_alert_response_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/close_incident_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/complete_alert_response_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_active_alerts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_by_id_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_history_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_settings_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_emergency_contacts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_incident_by_alert_id_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_pending_alerts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/stabilize_incident_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_source_type.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/severity.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/active_alerts/active_alerts_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/alert_detail_page.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/alert_detail_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_history/alert_history_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alerts/alerts_page.dart';

import '../alert_fakes.dart';
import '../fakes.dart';

void main() {
  late FakeAlertRepository alerts;
  late FakeIncidentRepository incidents;
  late FakeEmergencyContactRepository contacts;
  late FakeAlertSettingsRepository settings;
  late CareContextStore store;
  final clock = FixedServerClock();

  setUp(() {
    incidents = FakeIncidentRepository();
    contacts = FakeEmergencyContactRepository([contact('a', priorityOrder: 1).withName('María Rojas')]);
    settings = FakeAlertSettingsRepository();
    store = careContextStore();
    // The Alerts screen reads who is signed in from the service locator
    getIt.registerSingleton<CareContextStore>(store);
  });

  tearDown(getIt.reset);

  // A phone's width, tall enough that every section of these screens is built without scrolling
  Future<Widget> app(WidgetTester tester, Widget page) async {
    await tester.binding.setSurfaceSize(const Size(412, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    return MaterialApp(theme: GuardianTheme.light(), home: page);
  }

  AlertDetailViewModel detailViewModel(String alertId) => AlertDetailViewModel(
    alertId: alertId,
    getAlertById: GetAlertByIdUseCase(repository: alerts),
    getIncidentByAlertId: GetIncidentByAlertIdUseCase(repository: incidents),
    getEmergencyContacts: GetEmergencyContactsUseCase(repository: contacts),
    getAlertSettings: GetAlertSettingsUseCase(repository: settings),
    acknowledgeAlert: AcknowledgeAlertUseCase(repository: alerts),
    claimAlertResponse: ClaimAlertResponseUseCase(repository: alerts),
    completeAlertResponse: CompleteAlertResponseUseCase(repository: alerts),
    stabilizeIncident: StabilizeIncidentUseCase(repository: incidents),
    closeIncident: CloseIncidentUseCase(repository: incidents),
    serverClock: clock,
    careContextStore: store,
  );

  testWidgets('the Alerts screen features the critical alert with its countdown and lists the history', (tester) async {
    alerts = FakeAlertRepository(
      active: [
        alert('fall'),
        alert(
          'pill',
          source: AlertSourceType.medicationRestockSuggested,
          severity: Severity.medium,
          status: AlertStatus.acknowledged,
        ),
      ],
      pendingForMe: {'fall'},
      fullAlerts: {'fall': alert('fall', dispatchedAgo: const Duration(seconds: 18))},
      history: [alert('old', status: AlertStatus.resolved, acknowledgedAfter: const Duration(seconds: 48))],
    );

    await tester.pumpWidget(
      await app(
        tester,
        AlertsPage(
          activeAlertsViewModel: ActiveAlertsViewModel(
            getActiveAlerts: GetActiveAlertsUseCase(repository: alerts),
            getPendingAlerts: GetPendingAlertsUseCase(repository: alerts),
            getAlertById: GetAlertByIdUseCase(repository: alerts),
            acknowledgeAlert: AcknowledgeAlertUseCase(repository: alerts),
            getAlertSettings: GetAlertSettingsUseCase(repository: settings),
            getEmergencyContacts: GetEmergencyContactsUseCase(repository: contacts),
            serverClock: clock,
            careContextStore: store,
          ),
          alertHistoryViewModel: AlertHistoryViewModel(
            getAlertHistory: GetAlertHistoryUseCase(repository: alerts),
            serverClock: clock,
            careContextStore: store,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('2 activas'), findsOneWidget);
    expect(find.text('CRÍTICA · CAÍDA'), findsOneWidget);
    // 90 s timeout, dispatched 18 s ago
    expect(find.text('1:12'), findsOneWidget);
    expect(find.text('Reconocer'), findsOneWidget);
    expect(find.text('Otras alertas activas'), findsOneWidget);
    expect(find.text('Medicamento por agotarse'), findsOneWidget);

    await tester.tap(find.text('Historial'));
    await tester.pump();

    expect(find.text('Reconocida en 48 s'), findsOneWidget);
    expect(find.text('Resuelta'), findsOneWidget);
  });

  testWidgets('the detail offers the next step of the emergency route after each one', (tester) async {
    alerts = FakeAlertRepository(
      active: [
        alert('fall', deliveries: [delivery('maria')]),
      ],
    );

    await tester.pumpWidget(await app(tester, AlertDetailPage(viewModel: detailViewModel('fall'))));
    await tester.pump();

    expect(find.text('Detalle de alerta'), findsOneWidget);
    expect(find.text('Seguimiento del incidente'), findsOneWidget);
    expect(find.text('Caída detectada por la pulsera'), findsOneWidget);

    await tester.tap(find.text('Reconocer alerta'));
    await tester.pump();

    expect(find.text('Reconocer alerta'), findsNothing);
    expect(find.text('Voy en camino'), findsOneWidget);
    expect(alerts.calls, ['acknowledge fall by maria']);
  });

  testWidgets('stabilizing asks for optional notes and turns the detail into the incident summary', (tester) async {
    alerts = FakeAlertRepository(active: [alert('fall', status: AlertStatus.acknowledged)]);
    incidents = FakeIncidentRepository(incident('fall'));

    await tester.pumpWidget(await app(tester, AlertDetailPage(viewModel: detailViewModel('fall'))));
    await tester.pump();
    expect(find.text('En atención'), findsOneWidget);

    await tester.tap(find.text('Marcar estabilizado'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Marcar como estabilizado'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Ya está acostada');
    await tester.tap(find.widgetWithText(TextButton, 'Marcar estabilizado'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(incidents.calls, ['stabilize incident-fall notes=Ya está acostada']);
    expect(find.text('Incidente estabilizado'), findsWidgets);
    expect(find.text('Resumen del incidente'), findsOneWidget);
    expect(find.text('Ya está acostada'), findsOneWidget);
  });
}
