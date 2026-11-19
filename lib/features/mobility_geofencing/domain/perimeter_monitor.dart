import 'package:guardian_plus_app/features/mobility_geofencing/domain/geo_distance.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/location_reading.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/safe_zone.dart';

enum PerimeterTransition { exited, reentered }

/// A perimeter alert for the caregiver (EP04 scenarios 1 and 2).
class PerimeterEvent {
  final PerimeterTransition transition;
  final String? zoneName;
  final DateTime at;

  /// How far outside the zone limit the care recipient is. Only known when leaving.
  final double? distanceOutsideMeters;

  const PerimeterEvent({required this.transition, required this.at, this.zoneName, this.distanceOutsideMeters});
}

/// Domain rule: the care recipient left the perimeter only when [sustainedReadings] consecutive readings fall
/// outside every active safe zone (one stray GPS fix is not an exit); coming back is detected on the first reading
/// inside, which restores regular vigilance.
class PerimeterMonitor {
  final int sustainedReadings;

  PerimeterMonitor({required this.sustainedReadings}) : assert(sustainedReadings >= 1);

  int _outsideStreak = 0;
  bool _exitReported = false;
  String? _lastZoneName;

  bool get hasExited => _exitReported;

  void reset() {
    _outsideStreak = 0;
    _exitReported = false;
    _lastZoneName = null;
  }

  /// Feeds a reading and the active zones; returns the event it triggers, if any.
  PerimeterEvent? evaluate(LocationReading reading, List<SafeZone> activeZones) {
    if (activeZones.isEmpty) {
      reset();
      return null;
    }

    if (reading.insideSafeZone) {
      _outsideStreak = 0;
      final zoneName = reading.activeSafeZoneName;
      if (zoneName != null) _lastZoneName = zoneName;
      if (!_exitReported) return null;
      _exitReported = false;
      return PerimeterEvent(transition: PerimeterTransition.reentered, at: reading.timestamp, zoneName: zoneName ?? _lastZoneName);
    }

    _outsideStreak++;
    if (_exitReported || _outsideStreak < sustainedReadings) return null;

    _exitReported = true;
    final nearest = _nearestZone(reading, activeZones);
    final outside = distanceInMeters(reading.latitude, reading.longitude, nearest.latitude, nearest.longitude) -
        nearest.radiusMeters;
    return PerimeterEvent(
      transition: PerimeterTransition.exited,
      at: reading.timestamp,
      zoneName: nearest.name,
      distanceOutsideMeters: outside < 0 ? 0 : outside,
    );
  }

  SafeZone _nearestZone(LocationReading reading, List<SafeZone> zones) {
    double gap(SafeZone zone) =>
        distanceInMeters(reading.latitude, reading.longitude, zone.latitude, zone.longitude) - zone.radiusMeters;
    return zones.reduce((a, b) => gap(a) <= gap(b) ? a : b);
  }
}
