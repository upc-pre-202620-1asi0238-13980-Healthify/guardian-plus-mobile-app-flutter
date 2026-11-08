class UpdateAlertSettingsRequestDto {
  final int primaryAckTimeoutSec;
  final bool escalationEnabled;
  final bool broadcastCriticalImmediately;

  const new({
    required this.primaryAckTimeoutSec,
    required this.escalationEnabled,
    required this.broadcastCriticalImmediately,
  });

  Map<String, dynamic> toJson() {
    return {
      'primaryAckTimeoutSec': primaryAckTimeoutSec,
      'escalationEnabled': escalationEnabled,
      'broadcastCriticalImmediately': broadcastCriticalImmediately,
    };
  }
}
