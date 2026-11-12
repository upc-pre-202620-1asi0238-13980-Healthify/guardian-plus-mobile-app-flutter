import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/core/time/server_clock.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/acknowledge_alert_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_active_alerts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_by_id_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_settings_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_emergency_contacts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_pending_alerts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/severity.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/active_alerts/active_alerts_state.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/screen_states.dart';

/// Alerts of the person under care that are still in play, the most urgent one first (US08, US11, US15).
class ActiveAlertsViewModel extends ChangeNotifier {
  final GetActiveAlertsUseCase getActiveAlerts;
  final GetPendingAlertsUseCase getPendingAlerts;
  final GetAlertByIdUseCase getAlertById;
  final AcknowledgeAlertUseCase acknowledgeAlert;
  final GetAlertSettingsUseCase getAlertSettings;
  final GetEmergencyContactsUseCase getEmergencyContacts;
  // Countdowns follow the platform's clock, which decides when an alert escalates
  final ServerClock serverClock;
  final CareContextStore careContextStore;

  new({
    required this.getActiveAlerts,
    required this.getPendingAlerts,
    required this.getAlertById,
    required this.acknowledgeAlert,
    required this.getAlertSettings,
    required this.getEmergencyContacts,
    required this.serverClock,
    required this.careContextStore,
  }) {
    loadAlerts();
    _loadCallNumber();
    _clock = Timer.periodic(clockTick, (_) => _emit(_state.copyWith(now: serverClock.now())));
    // Escalations and new alerts happen on the platform, so the list is read again periodically
    _autoRefresh = Timer.periodic(autoRefreshInterval, (_) {
      if (!_state.isLoading) refresh();
    });
  }

  static const clockTick = Duration(seconds: 1);
  static const autoRefreshInterval = Duration(seconds: 10);

  // Whose data this screen shows: the signed-in account and the person under its care
  late final CareContext _careContext = careContextStore.require();

  late ActiveAlertsState _state = ActiveAlertsState(
    careRecipientName: _careContext.careRecipientName,
    now: serverClock.now(),
  );
  ActiveAlertsState get state => _state;

  late final Timer _clock;
  late final Timer _autoRefresh;
  bool _refreshing = false;
  bool _disposed = false;

  Future<void> loadAlerts() async {
    _emit(_state.copyWith(isLoading: true, errorMessage: () => null));
    await refresh();
  }

  Future<void> acknowledge(String alertId) async {
    if (_state.acknowledgingAlertId != null) return;
    _emit(_state.copyWith(acknowledgingAlertId: () => alertId));
    try {
      await acknowledgeAlert.execute(alertId: alertId, userId: _careContext.userAccountId);
      _emit(_state.copyWith(acknowledgingAlertId: () => null, acknowledgedAlertId: () => alertId));
      await refresh();
    } catch (e) {
      _emit(
        _state.copyWith(
          acknowledgingAlertId: () => null,
          actionErrorMessage: () => errorMessageOf(e, 'No se pudo reconocer la alerta'),
        ),
      );
    }
  }

  void onAcknowledgedAlertOpened() {
    _emit(_state.copyWith(acknowledgedAlertId: () => null));
  }

  void onActionErrorShown() {
    _emit(_state.copyWith(actionErrorMessage: () => null));
  }

  /// Reads the settings and the active alerts again; also called when coming back from an alert's detail.
  Future<void> refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      await _readSettings();
      final alerts = await getActiveAlerts.execute(_careContext.careRecipientProfileId);
      final myPendingIds = await _myPendingAlertIds();
      final items = ([...alerts]..sort(_byUrgency))
          .map((alert) => ActiveAlertItem(alert: alert, awaitsMyAcknowledgement: myPendingIds.contains(alert.id)))
          .toList();
      final featuredSummary = items.where(_isFeatured).firstOrNull;
      final featured = featuredSummary == null ? null : await _withDispatchTime(featuredSummary);
      _emit(
        _state.copyWith(
          isLoading: false,
          errorMessage: () => null,
          now: serverClock.now(),
          featuredAlert: () => featured,
          otherAlerts: items.where((item) => item.alert.id != featured?.alert.id).toList(),
        ),
      );
    } catch (e) {
      _emit(
        _state.copyWith(isLoading: false, errorMessage: () => errorMessageOf(e, 'No se pudieron cargar las alertas')),
      );
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _readSettings() async {
    try {
      final settings = await getAlertSettings.execute(_careContext.careRecipientProfileId);
      _emit(
        _state.copyWith(ackTimeoutSec: settings.primaryAckTimeoutSec, escalationEnabled: settings.escalationEnabled),
      );
    } catch (_) {
      // The countdown keeps the last known settings
    }
  }

  // Without them nobody can acknowledge from the list, but the alerts are still shown
  Future<Set<String>> _myPendingAlertIds() async {
    try {
      final pending = await getPendingAlerts.execute(_careContext.userAccountId);
      return pending.map((alert) => alert.id).toSet();
    } catch (_) {
      return {};
    }
  }

  /// List summaries do not carry lastDispatchedAt, which the countdown needs, so the full alert is read.
  Future<ActiveAlertItem> _withDispatchTime(ActiveAlertItem item) async {
    try {
      final full = await getAlertById.execute(item.alert.id);
      return ActiveAlertItem(alert: full, awaitsMyAcknowledgement: item.awaitsMyAcknowledgement);
    } catch (_) {
      return item;
    }
  }

  /// The "call" buttons dial the primary emergency contact, so its number is loaded with the alerts.
  Future<void> _loadCallNumber() async {
    try {
      final contacts = await getEmergencyContacts.execute(_careContext.careRecipientProfileId);
      final active = contacts.activeInOrder();
      careContextStore.updateCallNumber(active.isEmpty ? null : active.first.phoneNumber);
    } catch (_) {
      // The call button explains there is no number to call
    }
  }

  /// A critical alert still in play: waiting for the person under care or for an acknowledgement.
  static bool _isFeatured(ActiveAlertItem item) =>
      item.alert.severity == Severity.critical &&
      (item.alert.status == AlertStatus.pendingConfirmation || item.alert.status.isAwaitingAcknowledgement);

  // Critical first, then what still waits for an acknowledgement, then the most recent
  static int _byUrgency(Alert a, Alert b) {
    final bySeverity = a.severity.index.compareTo(b.severity.index);
    if (bySeverity != 0) return bySeverity;
    final byWaiting = (a.status.isAwaitingAcknowledgement ? 0 : 1).compareTo(
      b.status.isAwaitingAcknowledgement ? 0 : 1,
    );
    if (byWaiting != 0) return byWaiting;
    return b.triggeredAt.compareTo(a.triggeredAt);
  }

  void _emit(ActiveAlertsState state) {
    // A request can finish after the user has left the screen
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _clock.cancel();
    _autoRefresh.cancel();
    super.dispose();
  }
}
