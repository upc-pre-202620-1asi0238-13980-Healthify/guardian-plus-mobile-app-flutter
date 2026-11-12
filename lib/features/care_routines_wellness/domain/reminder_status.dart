enum ReminderStatus {
  scheduled,
  issued,
  confirmed,
  cancelled,
  reissued,
  suppressed,
  missed;

  /// Still waiting for the person under care: not issued yet, or issued and not confirmed.
  bool get isPending => this == scheduled || this == issued || this == reissued;

  /// Whether it belongs to the person's day. Reminders cancelled by the family or suppressed during the
  /// sleep window are not their responsibility, the same rule the platform applies to adherence.
  bool get countsTowardsDay => this != cancelled && this != suppressed;
}