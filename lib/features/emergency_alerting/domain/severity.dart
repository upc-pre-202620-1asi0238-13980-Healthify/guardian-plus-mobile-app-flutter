enum Severity {
  critical,
  high,
  medium;

  /// Only critical and high alerts escalate to the next contacts when nobody acknowledges them.
  bool get allowsEscalation => this == critical || this == high;
}
