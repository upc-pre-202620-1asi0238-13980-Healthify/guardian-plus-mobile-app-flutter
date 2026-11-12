import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/core/time/server_clock.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/acknowledge_alert_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/claim_alert_response_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/close_incident_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/complete_alert_response_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_by_id_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_settings_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_emergency_contacts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_incident_by_alert_id_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/stabilize_incident_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/alert_detail_state.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/screen_states.dart';

/// One alert and its incident: the emergency route from "Reconocer" to "Cerrar incidente" (US09, US25).
class AlertDetailViewModel extends ChangeNotifier {
  final String alertId;
  final GetAlertByIdUseCase getAlertById;
  final GetIncidentByAlertIdUseCase getIncidentByAlertId;
  final GetEmergencyContactsUseCase getEmergencyContacts;
  final GetAlertSettingsUseCase getAlertSettings;
  final AcknowledgeAlertUseCase acknowledgeAlert;
  final ClaimAlertResponseUseCase claimAlertResponse;
  final CompleteAlertResponseUseCase completeAlertResponse;
  final StabilizeIncidentUseCase stabilizeIncident;
  final CloseIncidentUseCase closeIncident;
  // Countdowns follow the platform's clock, which decides when an alert escalates
  final ServerClock serverClock;
  final CareContextStore careContextStore;

  new({
    required this.alertId,
    required this.getAlertById,
    required this.getIncidentByAlertId,
    required this.getEmergencyContacts,
    required this.getAlertSettings,
    required this.acknowledgeAlert,
    required this.claimAlertResponse,
    required this.completeAlertResponse,
    required this.stabilizeIncident,
    required this.closeIncident,
    required this.serverClock,
    required this.careContextStore,
  }) {
    load();
    _ticker = Timer.periodic(clockTick, (_) => _tick());
  }

  static const clockTick = Duration(seconds: 1);
  // Escalations and other members' answers happen on the platform, so the alert is read again this often
  static const refreshEverySeconds = 5;

  // Whose data this screen shows: the signed-in account and the person under its care
  late final CareContext _careContext = careContextStore.require();

  late AlertDetailState _state = AlertDetailState(
    careRecipientName: _careContext.careRecipientName,
    currentUserId: _careContext.userAccountId,
    now: serverClock.now(),
  );
  AlertDetailState get state => _state;

  late final Timer _ticker;
  int _seconds = 0;
  bool _refreshing = false;
  bool _disposed = false;

  Future<void> load() async {
    _emit(_state.copyWith(isLoading: true, errorMessage: () => null));
    await Future.wait([_loadContacts(), _loadSettings()]);
    await _refresh();
  }

  Future<void> acknowledge() => _runAction(
    AlertDetailAction.acknowledge,
    () => acknowledgeAlert.execute(alertId: alertId, userId: _careContext.userAccountId),
  );

  Future<void> claimResponse() => _runAction(
    AlertDetailAction.claim,
    () => claimAlertResponse.execute(alertId: alertId, responderUserId: _careContext.userAccountId),
  );

  Future<void> completeResponse() async {
    final responseId = _state.myActiveResponseId;
    if (responseId == null) return;
    await _runAction(
      AlertDetailAction.complete,
      () => completeAlertResponse.execute(alertId: alertId, responseId: responseId),
    );
  }

  Future<void> stabilize(String notes) async {
    final incidentId = _state.incident?.id;
    if (incidentId == null) return;
    await _runAction(
      AlertDetailAction.stabilize,
      () => stabilizeIncident.execute(incidentId: incidentId, notes: notes),
    );
  }

  Future<void> close(String notes) async {
    final incidentId = _state.incident?.id;
    if (incidentId == null) return;
    await _runAction(AlertDetailAction.close, () => closeIncident.execute(incidentId: incidentId, notes: notes));
  }

  void onActionErrorShown() {
    _emit(_state.copyWith(actionErrorMessage: () => null));
  }

  /// Runs a command, then reads the alert and its incident again so every card shows the new state.
  Future<void> _runAction(AlertDetailAction action, Future<Object?> Function() command) async {
    if (_state.runningAction != null) return;
    _emit(_state.copyWith(runningAction: () => action));
    try {
      await command();
      await _refresh(force: true);
      _emit(_state.copyWith(runningAction: () => null));
    } catch (e) {
      _emit(
        _state.copyWith(
          runningAction: () => null,
          actionErrorMessage: () => errorMessageOf(e, 'No se pudo completar la acción'),
        ),
      );
    }
  }

  Future<void> _refresh({bool force = false}) async {
    // The periodic read skips a turn while another one is still on its way; a command's read always runs
    if (_refreshing && !force) return;
    _refreshing = true;
    try {
      final alert = await getAlertById.execute(alertId);
      final incident = await _incidentOrNull();
      _emit(
        _state.copyWith(
          isLoading: false,
          errorMessage: () => null,
          alert: alert,
          incident: () => incident,
          now: serverClock.now(),
        ),
      );
    } catch (e) {
      _emit(_state.copyWith(isLoading: false, errorMessage: () => errorMessageOf(e, 'No se pudo cargar la alerta')));
    } finally {
      _refreshing = false;
    }
  }

  // Without the incident the alert still shows; the next read tries again
  Future<Incident?> _incidentOrNull() async {
    try {
      return await getIncidentByAlertId.execute(alertId);
    } catch (_) {
      return _state.incident;
    }
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await getEmergencyContacts.execute(_careContext.careRecipientProfileId);
      _emit(_state.copyWith(contacts: contacts));
      final active = contacts.activeInOrder();
      careContextStore.updateCallNumber(active.isEmpty ? null : active.first.phoneNumber);
    } catch (_) {
      // Names fall back to "Un miembro del círculo"
    }
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await getAlertSettings.execute(_careContext.careRecipientProfileId);
      _emit(
        _state.copyWith(ackTimeoutSec: settings.primaryAckTimeoutSec, escalationEnabled: settings.escalationEnabled),
      );
    } catch (_) {
      // The countdown uses the default timeout
    }
  }

  // Ticks the clock every second and, while the alert is still in play, reads it again every few seconds
  void _tick() {
    _seconds++;
    _emit(_state.copyWith(now: serverClock.now()));
    final state = _state;
    if (_seconds % refreshEverySeconds == 0 &&
        state.alert != null &&
        !state.isFinished &&
        state.runningAction == null) {
      _refresh();
    }
  }

  void _emit(AlertDetailState state) {
    // A request can finish after the user has left the screen
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker.cancel();
    super.dispose();
  }
}
