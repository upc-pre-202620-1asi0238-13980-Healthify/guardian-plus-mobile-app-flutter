/// What other bounded contexts know about the moment of an alert (Health Monitoring readings, Mobility location).
/// Emergency & Alerting does not own this data; it only shows it.
class AlertContext {
  final int? heartRateBpm;
  final int? oxygenSaturation;
  final String? locationName;
  // When the wristband sent the location, so the screen can say how long ago with its own clock
  final DateTime? locationUpdatedAt;

  const new({this.heartRateBpm, this.oxygenSaturation, this.locationName, this.locationUpdatedAt});

  static const empty = AlertContext();

  bool get hasVitals => heartRateBpm != null || oxygenSaturation != null;
}
