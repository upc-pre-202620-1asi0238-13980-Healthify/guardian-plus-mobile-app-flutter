import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/communication.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/location_reading.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/mobility_repositories.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/safe_zone.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/infrastructure/remote/mobility_geofencing_api.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/infrastructure/remote/mobility_mappers.dart';

/// "Nothing there yet" is a 404 for the platform; for the screens it is an empty state, not an error.
Future<T?> _nullOnNotFound<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on ApiException catch (error) {
    if (error.statusCode == 404) return null;
    rethrow;
  }
}

/// A JSON array of objects; a single object is read as a one-item list.
List<Map<String, dynamic>> _objects(dynamic json) {
  if (json is List) return json.cast<Map<String, dynamic>>();
  if (json is Map<String, dynamic>) return [json];
  throw FormatException('Unexpected response: expected a JSON array, got ${json.runtimeType}');
}

class LocationTrackingRepositoryImpl implements LocationTrackingRepository {
  final MobilityGeofencingApi api;

  const LocationTrackingRepositoryImpl({required this.api});

  @override
  Future<LocationReading?> getCurrent(String fragileCitizenId) {
    return _nullOnNotFound(() async => locationReadingFromJson(await api.getCurrentLocation(fragileCitizenId)));
  }

  @override
  Future<List<LocationReading>> getHistory(String fragileCitizenId) async {
    final json = await _nullOnNotFound(() => api.getLocationHistory(fragileCitizenId));
    if (json == null) return const [];
    return _objects(json).map(locationReadingFromJson).toList();
  }

  @override
  Future<MobilityStatus> getStatus(String fragileCitizenId) async {
    return mobilityStatusFromJson(await api.getMobilityStatus(fragileCitizenId));
  }
}

class SafeZoneRepositoryImpl implements SafeZoneRepository {
  final MobilityGeofencingApi api;

  const SafeZoneRepositoryImpl({required this.api});

  @override
  Future<List<SafeZone>> getSafeZones(String fragileCitizenId) async {
    final json = await _nullOnNotFound(() => api.getSafeZones(fragileCitizenId));
    if (json == null) return const [];
    return _objects(json).map(safeZoneFromJson).toList();
  }

  @override
  Future<void> create(String fragileCitizenId, SafeZoneDraft draft) async {
    // 201 answers with the new zone id as a plain string; the list is the source of truth
    await api.createSafeZone(createSafeZoneToJson(fragileCitizenId, draft));
  }

  @override
  Future<void> update(String safeZoneId, SafeZoneDraft draft) async {
    // 200 answers without a body
    await api.updateSafeZone(safeZoneId, updateSafeZoneToJson(draft));
  }

  @override
  Future<void> delete(String safeZoneId) async {
    await api.deleteSafeZone(safeZoneId);
  }

  @override
  Future<void> setActive(String safeZoneId, {required bool active}) async {
    await (active ? api.activateSafeZone(safeZoneId) : api.deactivateSafeZone(safeZoneId));
  }
}

class CommunicationRepositoryImpl implements CommunicationRepository {
  final MobilityGeofencingApi api;

  const CommunicationRepositoryImpl({required this.api});

  @override
  Future<DeviceCapabilities?> getDeviceCapabilities(String fragileCitizenId) {
    return _nullOnNotFound(() async => deviceCapabilitiesFromJson(await api.getDeviceCapabilities(fragileCitizenId)));
  }

  @override
  Future<CallSession> startCall(String fragileCitizenId, CallType requestedType) async {
    return callSessionFromJson(
      await api.startCall(startCallToJson(fragileCitizenId, requestedType)),
    );
  }

  @override
  Future<CallSession> endCall(String callId) async => callSessionFromJson(await api.endCall(callId));

  @override
  Future<List<CallLogEntry>> logUnanswered(String fragileCitizenId, CallType attemptedType, String reason) async {
    // Answers with the updated call log list
    final json = await api.logUnanswered(logUnansweredToJson(fragileCitizenId, attemptedType, reason));
    return _objects(json).map(callLogFromJson).toList();
  }

  @override
  Future<List<CallLogEntry>> getCallLogs(String fragileCitizenId) async {
    final json = await _nullOnNotFound(() => api.getCallLogs(fragileCitizenId));
    if (json == null) return const [];
    return _objects(json).map(callLogFromJson).toList();
  }

  @override
  Future<String?> sendHapticAlert(String fragileCitizenId, String message) async {
    // Answers with a map of strings; its first value is the platform's confirmation text
    final json = await api.sendHapticAlert(hapticAlertToJson(fragileCitizenId, message));
    if (json is Map && json.isNotEmpty) return json.values.first?.toString();
    return null;
  }
}
