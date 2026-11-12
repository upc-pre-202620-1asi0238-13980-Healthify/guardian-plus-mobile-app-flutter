import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_delivery.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_source_type.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/delivery_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/recipient_level.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/response_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/escalation.dart';

/// Commands the member can run from the detail; used to show progress on the right button.
enum AlertDetailAction { acknowledge, claim, complete, stabilize, close }

/// Where an emergency contact stands for this alert, from "not sent yet" to "arrived".
enum ContactStatus {
  waiting,
  sending,
  sent,
  delivered,
  failed,
  acknowledged,
  onTheWay,
  arrived,
  // Never reached because someone acknowledged before the escalation got to them
  notNeeded,
}

class EscalationContact {
  final EmergencyContact contact;
  final ContactStatus status;

  const new({required this.contact, required this.status});
}

/// What a line of "Seguimiento del incidente" says; the screen turns each kind into its sentence.
enum TimelineEventKind {
  detected,
  confirmed,
  dismissed,
  sentTo,
  acknowledged,
  onTheWay,
  arrived,
  stabilized,
  closed,
  // Not happened yet: when the alert will reach the next contacts if nobody acknowledges it
  nextEscalation,
}

class TimelineEvent {
  final TimelineEventKind kind;
  final DateTime at;
  // Who did it (acknowledged, on the way, arrived) or who received it (sentTo); empty when unknown
  final List<String> names;

  const new({required this.kind, required this.at, this.names = const []});
}

class AlertDetailState {
  const new({
    this.isLoading = false,
    this.errorMessage,
    this.alert,
    this.incident,
    this.contacts = const [],
    this.ackTimeoutSec = 60,
    this.escalationEnabled = true,
    this.careRecipientName = '',
    this.currentUserId = '',
    this.runningAction,
    this.actionErrorMessage,
    required this.now,
  });

  final bool isLoading;
  final String? errorMessage;
  final Alert? alert;
  final Incident? incident;
  final List<EmergencyContact> contacts;
  final int ackTimeoutSec;
  final bool escalationEnabled;
  final String careRecipientName;
  final String currentUserId;
  final AlertDetailAction? runningAction;
  final String? actionErrorMessage;
  final DateTime now;

  String get careRecipientFirstName => careRecipientName.split(' ').first;

  bool get _wasNotifiedToMe => alert?.deliveries.any((delivery) => delivery.recipientUserId == currentUserId) ?? false;

  bool get _incidentOpen => incident == null || incident!.status == IncidentStatus.inAttention;

  bool get isFinished =>
      alert?.status == AlertStatus.resolved ||
      alert?.status == AlertStatus.dismissed ||
      incident?.status == IncidentStatus.closed;

  /// Stabilized or over: the screen turns green and drops the emergency details.
  bool get isCalm => incident?.status == IncidentStatus.stabilized || isFinished;

  // The platform accepts these commands only from members the alert was sent to
  bool get canAcknowledge => (alert?.status.isAwaitingAcknowledgement ?? false) && _wasNotifiedToMe;

  // Once someone is on the way or already arrived, offering "Voy en camino" again would only confuse
  bool get canClaim {
    final alert = this.alert;
    if (alert == null || !_wasNotifiedToMe || !_incidentOpen) return false;
    final someoneResponding = alert.responses.any(
      (response) => response.status == ResponseStatus.claimed || response.status == ResponseStatus.completed,
    );
    return !someoneResponding && (alert.status.isAwaitingAcknowledgement || alert.status == AlertStatus.acknowledged);
  }

  /// "Llegué" is offered only to the member who said they were on the way.
  String? get myActiveResponseId {
    final response = alert?.activeResponse;
    return response != null && response.responderUserId == currentUserId ? response.id : null;
  }

  bool get canStabilize => incident?.status == IncidentStatus.inAttention;

  bool get canClose => incident != null && incident!.status != IncidentStatus.closed;

  int? get escalationSecondsLeft =>
      alert?.escalationSecondsLeft(ackTimeoutSec: ackTimeoutSec, escalationEnabled: escalationEnabled, now: now);

  int? get confirmationSecondsLeft => alert?.confirmationSecondsLeft(now);

  String? contactName(String? userId) {
    for (final contact in contacts) {
      if (contact.userId == userId) return contact.displayName;
    }
    return null;
  }

  /// Every active contact in escalation order, with how far the alert got with each of them.
  List<EscalationContact> get escalationContacts {
    final alert = this.alert;
    if (alert == null) return const [];
    return [
      for (final contact in contacts.activeInOrder())
        EscalationContact(contact: contact, status: _statusOf(alert, contact.userId)),
    ];
  }

  ContactStatus _statusOf(Alert alert, String userId) {
    final response = alert.responses.where((response) => response.responderUserId == userId).lastOrNull;
    final deliveries = alert.deliveries.where((delivery) => delivery.recipientUserId == userId).toList();
    if (response?.status == ResponseStatus.completed) return ContactStatus.arrived;
    if (response?.status == ResponseStatus.claimed) return ContactStatus.onTheWay;
    if (alert.acknowledgedByUserId == userId) return ContactStatus.acknowledged;
    if (deliveries.isEmpty && !alert.status.isAwaitingAcknowledgement) return ContactStatus.notNeeded;
    return _bestDeliveryStatus(deliveries);
  }

  // A contact may get the alert through several channels (in-app and SMS); the best outcome counts
  static ContactStatus _bestDeliveryStatus(List<AlertDelivery> deliveries) {
    bool any(DeliveryStatus status) => deliveries.any((delivery) => delivery.status == status);
    if (deliveries.isEmpty) return ContactStatus.waiting;
    if (any(DeliveryStatus.delivered)) return ContactStatus.delivered;
    if (any(DeliveryStatus.sent)) return ContactStatus.sent;
    if (any(DeliveryStatus.pending)) return ContactStatus.sending;
    return ContactStatus.failed;
  }

  /// What happened so far, oldest first, built only from the timestamps the platform recorded.
  List<TimelineEvent> get timeline {
    final alert = this.alert;
    if (alert == null) return const [];
    final events = [TimelineEvent(kind: TimelineEventKind.detected, at: alert.triggeredAt)];
    // Only falls have a confirmation window; other sources are confirmed the moment they arrive
    if (alert.sourceType == AlertSourceType.fallDetected && alert.confirmedAt != null) {
      events.add(TimelineEvent(kind: TimelineEventKind.confirmed, at: alert.confirmedAt!));
    }
    if (alert.status == AlertStatus.dismissed) {
      events.add(TimelineEvent(kind: TimelineEventKind.dismissed, at: alert.resolvedAt ?? alert.triggeredAt));
    }
    // One line per dispatch wave (primary, secondary, everyone)
    final waves = <RecipientLevel, List<AlertDelivery>>{};
    for (final delivery in alert.deliveries.where((delivery) => delivery.sentAt != null)) {
      waves.putIfAbsent(delivery.recipientLevel, () => []).add(delivery);
    }
    for (final wave in waves.values) {
      final sentAt = wave.map((delivery) => delivery.sentAt!).reduce((a, b) => a.isBefore(b) ? a : b);
      final names = {for (final delivery in wave) ?contactName(delivery.recipientUserId)}.toList();
      events.add(TimelineEvent(kind: TimelineEventKind.sentTo, at: sentAt, names: names));
    }
    if (alert.acknowledgedAt != null) {
      events.add(
        TimelineEvent(
          kind: TimelineEventKind.acknowledged,
          at: alert.acknowledgedAt!,
          names: [?contactName(alert.acknowledgedByUserId)],
        ),
      );
    }
    for (final response in alert.responses) {
      final names = [?contactName(response.responderUserId)];
      events.add(TimelineEvent(kind: TimelineEventKind.onTheWay, at: response.claimedAt, names: names));
      if (response.completedAt != null) {
        events.add(TimelineEvent(kind: TimelineEventKind.arrived, at: response.completedAt!, names: names));
      }
    }
    if (incident?.stabilizedAt != null) {
      events.add(TimelineEvent(kind: TimelineEventKind.stabilized, at: incident!.stabilizedAt!));
    }
    if (incident?.closedAt != null) {
      events.add(TimelineEvent(kind: TimelineEventKind.closed, at: incident!.closedAt!));
    }
    final left = escalationSecondsLeft;
    if (alert.currentRecipientLevel != RecipientLevel.broadcast && left != null) {
      events.add(
        TimelineEvent(
          kind: TimelineEventKind.nextEscalation,
          at: now.add(Duration(seconds: left)),
        ),
      );
    }
    // Stable sort: events recorded at the same instant keep the order above
    mergeSort(events, compare: (a, b) => a.at.compareTo(b.at));
    return events;
  }

  // Nullable fields take a function, so copyWith can also set them back to null
  AlertDetailState copyWith({
    bool? isLoading,
    ValueGetter<String?>? errorMessage,
    Alert? alert,
    ValueGetter<Incident?>? incident,
    List<EmergencyContact>? contacts,
    int? ackTimeoutSec,
    bool? escalationEnabled,
    ValueGetter<AlertDetailAction?>? runningAction,
    ValueGetter<String?>? actionErrorMessage,
    DateTime? now,
  }) {
    return AlertDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      alert: alert ?? this.alert,
      incident: incident != null ? incident() : this.incident,
      contacts: contacts ?? this.contacts,
      ackTimeoutSec: ackTimeoutSec ?? this.ackTimeoutSec,
      escalationEnabled: escalationEnabled ?? this.escalationEnabled,
      careRecipientName: careRecipientName,
      currentUserId: currentUserId,
      runningAction: runningAction != null ? runningAction() : this.runningAction,
      actionErrorMessage: actionErrorMessage != null ? actionErrorMessage() : this.actionErrorMessage,
      now: now ?? this.now,
    );
  }
}
