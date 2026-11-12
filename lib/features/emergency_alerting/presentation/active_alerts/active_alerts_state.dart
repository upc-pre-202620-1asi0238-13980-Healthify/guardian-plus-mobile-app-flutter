import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/escalation.dart';

/// An active alert plus what the screen needs to draw it.
class ActiveAlertItem {
  final Alert alert;
  // The platform only accepts the acknowledgement of members the alert was sent to
  final bool awaitsMyAcknowledgement;

  const new({required this.alert, this.awaitsMyAcknowledgement = false});
}

class ActiveAlertsState {
  const new({
    this.isLoading = false,
    this.errorMessage,
    this.careRecipientName = '',
    this.featuredAlert,
    this.otherAlerts = const [],
    this.ackTimeoutSec = 60,
    this.escalationEnabled = true,
    this.acknowledgingAlertId,
    this.actionErrorMessage,
    this.acknowledgedAlertId,
    required this.now,
  });

  final bool isLoading;
  final String? errorMessage;
  final String careRecipientName;
  // The most urgent critical alert, drawn as the red card at the top
  final ActiveAlertItem? featuredAlert;
  final List<ActiveAlertItem> otherAlerts;
  final int ackTimeoutSec;
  final bool escalationEnabled;
  final String? acknowledgingAlertId;
  final String? actionErrorMessage;
  // Set after a successful acknowledgement so the screen opens that alert (emergency route, step 3)
  final String? acknowledgedAlertId;
  // Ticks every second so relative times and the countdown keep moving
  final DateTime now;

  String get careRecipientFirstName => careRecipientName.split(' ').first;

  int get activeCount => otherAlerts.length + (featuredAlert != null ? 1 : 0);

  /// Seconds left before the featured alert escalates to the next contacts, or null when it will not escalate.
  int? get escalationSecondsLeft => featuredAlert?.alert.escalationSecondsLeft(
    ackTimeoutSec: ackTimeoutSec,
    escalationEnabled: escalationEnabled,
    now: now,
  );

  // Nullable fields take a function, so copyWith can also set them back to null
  ActiveAlertsState copyWith({
    bool? isLoading,
    ValueGetter<String?>? errorMessage,
    ValueGetter<ActiveAlertItem?>? featuredAlert,
    List<ActiveAlertItem>? otherAlerts,
    int? ackTimeoutSec,
    bool? escalationEnabled,
    ValueGetter<String?>? acknowledgingAlertId,
    ValueGetter<String?>? actionErrorMessage,
    ValueGetter<String?>? acknowledgedAlertId,
    DateTime? now,
  }) {
    return ActiveAlertsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      careRecipientName: careRecipientName,
      featuredAlert: featuredAlert != null ? featuredAlert() : this.featuredAlert,
      otherAlerts: otherAlerts ?? this.otherAlerts,
      ackTimeoutSec: ackTimeoutSec ?? this.ackTimeoutSec,
      escalationEnabled: escalationEnabled ?? this.escalationEnabled,
      acknowledgingAlertId: acknowledgingAlertId != null ? acknowledgingAlertId() : this.acknowledgingAlertId,
      actionErrorMessage: actionErrorMessage != null ? actionErrorMessage() : this.actionErrorMessage,
      acknowledgedAlertId: acknowledgedAlertId != null ? acknowledgedAlertId() : this.acknowledgedAlertId,
      now: now ?? this.now,
    );
  }
}
