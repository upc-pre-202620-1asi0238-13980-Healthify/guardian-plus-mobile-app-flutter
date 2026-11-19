/// A GPS reading of the care recipient, as reported by the platform.
class LocationReading {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? speed;
  final DateTime timestamp;
  final bool insideSafeZone;
  final String? activeSafeZoneId;
  final String? activeSafeZoneName;

  const LocationReading({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.insideSafeZone,
    this.accuracy,
    this.speed,
    this.activeSafeZoneId,
    this.activeSafeZoneName,
  });
}

/// Mobility and perimeter status of the care recipient.
class MobilityStatus {
  final bool isInsideSafeZone;
  final String status;
  final DateTime? lastUpdated;
  final String? currentSafeZoneName;

  const MobilityStatus({
    required this.isInsideSafeZone,
    required this.status,
    this.lastUpdated,
    this.currentSafeZoneName,
  });
}
