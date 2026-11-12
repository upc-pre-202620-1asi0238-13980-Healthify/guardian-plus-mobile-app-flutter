import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/fall_confirmation_window.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/recipient_level.dart';

extension AlertEscalation on Alert {
  /// Seconds left before the alert escalates to the next contacts, or null when it will not escalate
  /// (escalation off, already sent to everyone, or not waiting for an acknowledgement). Mirrors the platform's
  /// AckTimeoutEscalationScheduler, which counts from the last dispatch.
  int? escalationSecondsLeft({required int ackTimeoutSec, required bool escalationEnabled, required DateTime now}) {
    final dispatchedAt = lastDispatchedAt;
    if (dispatchedAt == null) return null;
    final willEscalate =
        escalationEnabled &&
        severity.allowsEscalation &&
        status.isAwaitingAcknowledgement &&
        currentRecipientLevel != RecipientLevel.broadcast;
    if (!willEscalate) return null;
    final left = ackTimeoutSec - now.difference(dispatchedAt).inSeconds;
    return left < 0 ? 0 : left;
  }

  /// Seconds the person under care still has to cancel a detected fall, or null outside that window.
  int? confirmationSecondsLeft(DateTime now) {
    if (status != AlertStatus.pendingConfirmation) return null;
    final left = FallConfirmationWindow.seconds - now.difference(triggeredAt).inSeconds;
    return left < 0 ? 0 : left;
  }
}
