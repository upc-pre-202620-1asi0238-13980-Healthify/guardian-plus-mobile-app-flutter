import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
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
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/recipient_level.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/severity.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/active_alerts/active_alerts_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/alert_detail_state.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/alert_detail_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_history/alert_history_view_model.dart';

import '../alert_fakes.dart';
import '../fakes.dart';

void main() {
  late FakeAlertRepository alerts;
  late FakeIncidentRepository incidents;
  late FakeEmergencyContactRepository contacts;
  late FakeAlertSettingsRepository settings;
  late CareContextStore store;
  late FixedServerClock clock;

  setUp(() {
    alerts = FakeAlertRepository();
    incidents = FakeIncidentRepository();
    contacts = FakeEmergencyContactRepository([contact('a', priorityOrder: 1, phoneNumber: '+51987000111')]);
    settings = FakeAlertSettingsRepository();
    store = careContextStore();
    clock = FixedServerClock();
  });

  group('ActiveAlertsViewModel', () {
    ActiveAlertsViewModel create() {
      final viewModel = ActiveAlertsViewModel(
        getActiveAlerts: GetActiveAlertsUseCase(repository: alerts),
        getPendingAlerts: GetPendingAlertsUseCase(repository: alerts),
        getAlertById: GetAlertByIdUseCase(repository: alerts),
        acknowledgeAlert: AcknowledgeAlertUseCase(repository: alerts),
        getAlertSettings: GetAlertSettingsUseCase(repository: settings),
        getEmergencyContacts: GetEmergencyContactsUseCase(repository: contacts),
        serverClock: clock,
        careContextStore: store,
      );
      addTearDown(viewModel.dispose);
      return viewModel;
    }

    test('features the critical alert still in play and sorts the rest by urgency', () async {
      final fall = alert('fall', ago: const Duration(minutes: 2));
      alerts = FakeAlertRepository(
        active: [
          alert('pill', severity: Severity.medium, status: AlertStatus.acknowledged, ago: const Duration(minutes: 1)),
          alert('hr', source: AlertSourceType.vitalSignAnomaly, severity: Severity.high),
          fall,
        ],
        pendingForMe: {'fall'},
        // Only the full alert carries the last dispatch, which the countdown needs
        fullAlerts: {
          'fall': alert('fall', ago: const Duration(minutes: 2), dispatchedAgo: const Duration(seconds: 18)),
        },
      );

      final viewModel = create();
      await pumpEventQueue();

      final state = viewModel.state;
      expect(state.featuredAlert?.alert.id, 'fall');
      expect(state.featuredAlert?.awaitsMyAcknowledgement, isTrue);
      expect(state.otherAlerts.map((item) => item.alert.id), ['hr', 'pill']);
      expect(state.activeCount, 3);
      expect(state.ackTimeoutSec, 90);
      expect(state.escalationSecondsLeft, 72);
      // The call buttons dial the primary emergency contact
      expect(store.current!.callNumber, '+51987000111');
    });

    test('acknowledging asks to open that alert and reads the list again', () async {
      alerts = FakeAlertRepository(active: [alert('fall')], pendingForMe: {'fall'});
      final viewModel = create();
      await pumpEventQueue();

      await viewModel.acknowledge('fall');

      expect(alerts.calls, ['acknowledge fall by maria']);
      expect(viewModel.state.acknowledgedAlertId, 'fall');
      expect(viewModel.state.featuredAlert, isNull, reason: 'an acknowledged alert is no longer featured');
      viewModel.onAcknowledgedAlertOpened();
      expect(viewModel.state.acknowledgedAlertId, isNull);
    });

    test('a rejected acknowledgement says why and keeps the list', () async {
      alerts = FakeAlertRepository(active: [alert('fall')], pendingForMe: {'fall'});
      final viewModel = create();
      await pumpEventQueue();
      alerts.commandFailure = const ApiException('Otro miembro ya reconoció la alerta');

      await viewModel.acknowledge('fall');

      expect(viewModel.state.actionErrorMessage, 'Otro miembro ya reconoció la alerta');
      expect(viewModel.state.acknowledgingAlertId, isNull);
      expect(viewModel.state.featuredAlert?.alert.id, 'fall');
    });

    test('shows why the alerts could not be loaded', () async {
      alerts.failure = const ApiException('No se pudo conectar con el servidor. Revisa tu conexión.');
      final viewModel = create();
      await pumpEventQueue();

      expect(viewModel.state.errorMessage, 'No se pudo conectar con el servidor. Revisa tu conexión.');
      expect(viewModel.state.isLoading, isFalse);
    });
  });

  group('AlertHistoryViewModel', () {
    AlertHistoryViewModel create() {
      final viewModel = AlertHistoryViewModel(
        getAlertHistory: GetAlertHistoryUseCase(repository: alerts),
        serverClock: clock,
        careContextStore: store,
      );
      addTearDown(viewModel.dispose);
      return viewModel;
    }

    test('loads pages as the list reaches its end, without repeating alerts', () async {
      alerts = FakeAlertRepository(
        history: [
          for (var i = 0; i < 25; i++)
            alert(
              'h$i',
              ago: Duration(hours: i),
              status: AlertStatus.resolved,
            ),
        ],
      );
      final viewModel = create();
      await pumpEventQueue();
      expect(viewModel.state.alerts, hasLength(20));
      expect(viewModel.state.isLastPage, isFalse);

      await viewModel.loadMore();
      await viewModel.loadMore();

      expect(viewModel.state.alerts, hasLength(25));
      expect(viewModel.state.isLastPage, isTrue);
      expect(alerts.historyRequests.where((r) => r.from == null).map((r) => r.page), [0, 1]);
    });

    test('a severity filter reloads from the first page', () async {
      alerts = FakeAlertRepository(
        history: [
          alert('c', severity: Severity.critical, status: AlertStatus.resolved),
          alert('m', severity: Severity.medium, status: AlertStatus.resolved),
        ],
      );
      final viewModel = create();
      await pumpEventQueue();

      await viewModel.selectSeverity(Severity.medium);

      expect(viewModel.state.alerts.map((a) => a.id), ['m']);
      expect(viewModel.state.severityFilter, Severity.medium);
    });

    test('the week summary counts every severity, the mean response and the escalated alerts', () async {
      alerts = FakeAlertRepository(
        history: [
          alert('a', status: AlertStatus.resolved, acknowledgedAfter: const Duration(seconds: 40)),
          alert('b', status: AlertStatus.resolved, acknowledgedAfter: const Duration(seconds: 80)),
          alert('c', severity: Severity.medium, status: AlertStatus.dismissed, level: RecipientLevel.secondary),
        ],
      );
      final viewModel = create();
      await pumpEventQueue();

      final summary = viewModel.state.summary!;
      expect(summary.totalAlerts, 3);
      expect(summary.averageResponseSec, 60);
      expect(summary.escalatedCount, 1);
      expect(alerts.historyRequests.firstWhere((r) => r.from != null).size, 100);
    });
  });

  group('AlertDetailViewModel', () {
    AlertDetailViewModel create(String alertId) {
      final viewModel = AlertDetailViewModel(
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
      addTearDown(viewModel.dispose);
      return viewModel;
    }

    test('runs the emergency route: acknowledge, on my way, arrived', () async {
      alerts = FakeAlertRepository(
        active: [
          alert('fall', deliveries: [delivery('maria')]),
        ],
      );
      final viewModel = create('fall');
      await pumpEventQueue();
      expect(viewModel.state.canAcknowledge, isTrue);

      await viewModel.acknowledge();
      expect(viewModel.state.alert!.status, AlertStatus.acknowledged);
      expect(viewModel.state.canClaim, isTrue);

      await viewModel.claimResponse();
      expect(viewModel.state.myActiveResponseId, 'response-maria');

      await viewModel.completeResponse();
      expect(alerts.calls, [
        'acknowledge fall by maria',
        'claim fall by maria',
        'complete fall response response-maria',
      ]);
      expect(viewModel.state.myActiveResponseId, isNull);
      expect(viewModel.state.runningAction, isNull);
    });

    test('stabilizing and closing send the notes, and blank notes are not sent', () async {
      alerts = FakeAlertRepository(active: [alert('fall', status: AlertStatus.acknowledged)]);
      incidents = FakeIncidentRepository(incident('fall'));
      final viewModel = create('fall');
      await pumpEventQueue();

      await viewModel.stabilize('  Caída sin lesiones ');
      expect(viewModel.state.incident!.status, IncidentStatus.stabilized);
      await viewModel.close('   ');

      expect(incidents.calls, ['stabilize incident-fall notes=Caída sin lesiones', 'close incident-fall notes=null']);
      expect(viewModel.state.isFinished, isTrue);
    });

    test('a rejected command says why and frees the buttons', () async {
      alerts = FakeAlertRepository(
        active: [
          alert('fall', deliveries: [delivery('maria')]),
        ],
      );
      final viewModel = create('fall');
      await pumpEventQueue();
      alerts.commandFailure = const ApiException('La alerta ya fue reconocida');

      await viewModel.acknowledge();

      expect(viewModel.state.actionErrorMessage, 'La alerta ya fue reconocida');
      expect(viewModel.state.runningAction, isNull);
    });

    test('a second command is ignored while one is running', () async {
      alerts = FakeAlertRepository(
        active: [
          alert('fall', deliveries: [delivery('maria')]),
        ],
      );
      final viewModel = create('fall');
      await pumpEventQueue();

      final first = viewModel.acknowledge();
      expect(viewModel.state.runningAction, AlertDetailAction.acknowledge);
      await viewModel.claimResponse();
      await first;

      expect(alerts.calls, ['acknowledge fall by maria']);
    });
  });
}
