/// How the alerts of one person under care escalate and sound.
class AlertSettings {
  final String careRecipientProfileId;
  final int primaryAckTimeoutSec;
  final bool escalationEnabled;
  // Non-critical alerts reach the Care Circle phones without sound (US22)
  final bool silentModeEnabled;
  final bool broadcastCriticalImmediately;

  const new({
    required this.careRecipientProfileId,
    required this.primaryAckTimeoutSec,
    required this.escalationEnabled,
    required this.silentModeEnabled,
    required this.broadcastCriticalImmediately,
  });

  AlertSettings copyWith({
    int? primaryAckTimeoutSec,
    bool? escalationEnabled,
    bool? silentModeEnabled,
    bool? broadcastCriticalImmediately,
  }) {
    return AlertSettings(
      careRecipientProfileId: careRecipientProfileId,
      primaryAckTimeoutSec: primaryAckTimeoutSec ?? this.primaryAckTimeoutSec,
      escalationEnabled: escalationEnabled ?? this.escalationEnabled,
      silentModeEnabled: silentModeEnabled ?? this.silentModeEnabled,
      broadcastCriticalImmediately: broadcastCriticalImmediately ?? this.broadcastCriticalImmediately,
    );
  }
}

/// Limits the platform accepts for the acknowledgement timeout (AckTimeout value object).
abstract final class AckTimeoutLimits {
  static const minSeconds = 15;
  static const maxSeconds = 300;
}
