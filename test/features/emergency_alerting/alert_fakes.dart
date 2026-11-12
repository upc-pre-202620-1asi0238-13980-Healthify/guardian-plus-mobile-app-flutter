import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/core/time/server_clock.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_delivery.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_page.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_response.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_source_type.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/delivery_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/notification_channel.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/recipient_level.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/response_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/severity.dart';

import 'fakes.dart';

/// The instant every test treats as "now", so countdowns are exact.
final testNow = DateTime.utc(2026, 11, 12, 14, 33, 5);

/// A clock that stays where the test puts it.
class FixedServerClock extends ServerClock {
  DateTime current;

  new([DateTime? now]) : current = now ?? testNow;

  @override
  DateTime now() => current;
}

Alert alert(
  String id, {
  AlertSourceType source = AlertSourceType.fallDetected,
  Severity severity = Severity.critical,
  AlertStatus status = AlertStatus.triggered,
  RecipientLevel? level = RecipientLevel.primary,
  Duration ago = const Duration(minutes: 1),
  Duration? dispatchedAgo,
  Duration? acknowledgedAfter,
  String? acknowledgedBy,
  List<AlertDelivery> deliveries = const [],
  List<AlertResponse> responses = const [],
}) {
  final triggeredAt = testNow.subtract(ago);
  return Alert(
    id: id,
    careRecipientProfileId: careRecipientId,
    sourceType: source,
    severity: severity,
    status: status,
    currentRecipientLevel: level,
    triggeredAt: triggeredAt,
    acknowledgedAt: acknowledgedAfter == null ? null : triggeredAt.add(acknowledgedAfter),
    acknowledgedByUserId: acknowledgedBy,
    lastDispatchedAt: dispatchedAgo == null ? null : testNow.subtract(dispatchedAgo),
    deliveries: deliveries,
    responses: responses,
  );
}

AlertDelivery delivery(
  String userId, {
  RecipientLevel level = RecipientLevel.primary,
  DeliveryStatus status = DeliveryStatus.delivered,
  Duration sentAgo = const Duration(seconds: 50),
}) {
  return AlertDelivery(
    id: 'delivery-$userId-${level.name}',
    recipientUserId: userId,
    recipientLevel: level,
    channel: NotificationChannel.inApp,
    status: status,
    sentAt: testNow.subtract(sentAgo),
  );
}

AlertResponse response(
  String userId, {
  ResponseStatus status = ResponseStatus.claimed,
  Duration claimedAgo = const Duration(seconds: 20),
}) {
  return AlertResponse(
    id: 'response-$userId',
    responderUserId: userId,
    status: status,
    claimedAt: testNow.subtract(claimedAgo),
    completedAt: status == ResponseStatus.completed ? testNow.subtract(const Duration(seconds: 5)) : null,
  );
}

/// Keeps the alerts in memory and follows the platform's rules for the commands the screens send.
class FakeAlertRepository implements AlertRepository {
  List<Alert> active;
  Set<String> pendingForMe;
  Map<String, Alert> fullAlerts;
  List<Alert> history;
  ApiException? failure;
  ApiException? commandFailure;
  final List<String> calls = [];
  final List<({Severity? severity, DateTime? from, int page, int size})> historyRequests = [];

  new({this.active = const [], this.pendingForMe = const {}, Map<String, Alert>? fullAlerts, this.history = const []})
    : fullAlerts = fullAlerts ?? {};

  @override
  Future<List<Alert>> getActiveAlerts(String careRecipientProfileId) async {
    if (failure != null) throw failure!;
    return active;
  }

  @override
  Future<List<Alert>> getPendingAlerts(String userId) async =>
      active.where((a) => pendingForMe.contains(a.id)).toList();

  @override
  Future<Alert> getAlertById(String alertId) async {
    if (failure != null) throw failure!;
    return fullAlerts[alertId] ?? active.firstWhere((a) => a.id == alertId);
  }

  @override
  Future<AlertPage> getAlertHistory({
    required String careRecipientProfileId,
    Severity? severity,
    DateTime? from,
    DateTime? to,
    required int page,
    required int size,
  }) async {
    historyRequests.add((severity: severity, from: from, page: page, size: size));
    if (failure != null) throw failure!;
    final matching = history.where((a) => severity == null || a.severity == severity).toList();
    final totalPages = matching.isEmpty ? 0 : (matching.length / size).ceil();
    final start = page * size;
    return AlertPage(
      alerts: start >= matching.length ? [] : matching.sublist(start, (start + size).clamp(0, matching.length)),
      page: page,
      totalPages: totalPages,
      totalElements: matching.length,
    );
  }

  @override
  Future<Alert> acknowledgeAlert({required String alertId, required String userId}) async {
    calls.add('acknowledge $alertId by $userId');
    if (commandFailure != null) throw commandFailure!;
    return _replace(alertId, (a) => _copy(a, status: AlertStatus.acknowledged, acknowledgedBy: userId));
  }

  @override
  Future<Alert> claimAlertResponse({required String alertId, required String responderUserId}) async {
    calls.add('claim $alertId by $responderUserId');
    if (commandFailure != null) throw commandFailure!;
    return _replace(
      alertId,
      (a) => _copy(
        a,
        status: AlertStatus.acknowledged,
        acknowledgedBy: responderUserId,
        responses: [
          ...a.responses,
          response(responderUserId, claimedAgo: Duration.zero),
        ],
      ),
    );
  }

  @override
  Future<Alert> completeAlertResponse({required String alertId, required String responseId, String? notes}) async {
    calls.add('complete $alertId response $responseId');
    if (commandFailure != null) throw commandFailure!;
    return _replace(
      alertId,
      (a) => _copy(
        a,
        responses: [
          for (final r in a.responses)
            r.id == responseId ? response(r.responderUserId, status: ResponseStatus.completed) : r,
        ],
      ),
    );
  }

  Alert _replace(String alertId, Alert Function(Alert) change) {
    final updated = change(fullAlerts[alertId] ?? active.firstWhere((a) => a.id == alertId));
    fullAlerts[alertId] = updated;
    active = [for (final a in active) a.id == alertId ? updated : a];
    pendingForMe = {...pendingForMe}..remove(alertId);
    return updated;
  }

  static Alert _copy(Alert a, {AlertStatus? status, String? acknowledgedBy, List<AlertResponse>? responses}) {
    return Alert(
      id: a.id,
      careRecipientProfileId: a.careRecipientProfileId,
      sourceType: a.sourceType,
      severity: a.severity,
      status: status ?? a.status,
      currentRecipientLevel: a.currentRecipientLevel,
      triggeredAt: a.triggeredAt,
      acknowledgedAt: acknowledgedBy != null ? testNow : a.acknowledgedAt,
      acknowledgedByUserId: acknowledgedBy ?? a.acknowledgedByUserId,
      lastDispatchedAt: a.lastDispatchedAt,
      deliveries: a.deliveries,
      responses: responses ?? a.responses,
    );
  }
}

class FakeIncidentRepository implements IncidentRepository {
  Incident? incident;
  final List<String> calls = [];

  new([this.incident]);

  @override
  Future<Incident?> getIncidentByAlertId(String alertId) async => incident;

  @override
  Future<Incident> stabilizeIncident({required String incidentId, String? notes}) async {
    calls.add('stabilize $incidentId notes=$notes');
    return incident = _with(IncidentStatus.stabilized, notes);
  }

  @override
  Future<Incident> closeIncident({required String incidentId, String? notes}) async {
    calls.add('close $incidentId notes=$notes');
    return incident = _with(IncidentStatus.closed, notes);
  }

  Incident _with(IncidentStatus status, String? notes) {
    final current = incident!;
    return Incident(
      id: current.id,
      alertId: current.alertId,
      status: status,
      markedInAttentionAt: current.markedInAttentionAt,
      stabilizedAt: status == IncidentStatus.stabilized ? testNow : current.stabilizedAt,
      closedAt: status == IncidentStatus.closed ? testNow : null,
      notes: notes,
    );
  }
}

Incident incident(String alertId, {IncidentStatus status = IncidentStatus.inAttention}) {
  return Incident(
    id: 'incident-$alertId',
    alertId: alertId,
    status: status,
    markedInAttentionAt: testNow.subtract(const Duration(seconds: 30)),
  );
}
