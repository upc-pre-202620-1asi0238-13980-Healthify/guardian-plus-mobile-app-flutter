enum AlertStatus {
  pendingConfirmation,
  triggered,
  escalated,
  acknowledged,
  dismissed,
  resolved;

  /// A Care Circle member can acknowledge the alert only in these states.
  bool get isAwaitingAcknowledgement => this == triggered || this == escalated;
}
