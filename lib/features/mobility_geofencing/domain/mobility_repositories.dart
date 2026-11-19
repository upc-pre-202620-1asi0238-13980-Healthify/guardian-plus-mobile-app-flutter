import 'package:guardian_plus_app/features/mobility_geofencing/domain/communication.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/location_reading.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/safe_zone.dart';

abstract class LocationTrackingRepository {
  /// Null when the platform has no reading of the care recipient yet.
  Future<LocationReading?> getCurrent(String fragileCitizenId);

  Future<List<LocationReading>> getHistory(String fragileCitizenId);

  Future<MobilityStatus> getStatus(String fragileCitizenId);
}

abstract class SafeZoneRepository {
  Future<List<SafeZone>> getSafeZones(String fragileCitizenId);

  Future<SafeZone> create(String fragileCitizenId, SafeZoneDraft draft);

  Future<SafeZone> update(String safeZoneId, SafeZoneDraft draft);

  Future<void> delete(String safeZoneId);

  Future<void> setActive(String safeZoneId, {required bool active});
}

abstract class CommunicationRepository {
  /// Null when the care recipient has no wearable linked.
  Future<DeviceCapabilities?> getDeviceCapabilities(String fragileCitizenId);

  Future<CallSession> startCall(String fragileCitizenId, CallType requestedType);

  Future<CallSession> endCall(String callId);

  Future<void> logUnanswered(String fragileCitizenId, CallType attemptedType, int timeoutSeconds);

  Future<List<CallLogEntry>> getCallLogs(String fragileCitizenId);

  Future<void> sendHapticAlert(String fragileCitizenId, String reason);
}
