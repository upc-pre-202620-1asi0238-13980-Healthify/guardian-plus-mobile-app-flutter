import 'dart:async';

import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/communication.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/location_reading.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/mobility_repositories.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/safe_zone.dart';

/// In-memory test doubles. The values here exist only in tests.

CareContextStore fakeCareContextStore() {
  return CareContextStore()
    ..save(
      const CareContext(
        userAccountId: 'user-test',
        userFullName: 'Cuidador Prueba',
        careRecipientProfileId: 'citizen-test',
        careRecipientName: 'Paciente Prueba',
      ),
    );
}

SafeZone testZone({String id = 'z1', double lat = 10, double lon = 20, double radius = 100, bool active = true}) {
  return SafeZone(
    id: id,
    fragileCitizenId: 'citizen-test',
    name: 'Zona $id',
    latitude: lat,
    longitude: lon,
    radiusMeters: radius,
    isActive: active,
  );
}

LocationReading testReading({
  double lat = 10,
  double lon = 20,
  bool inside = true,
  String? zoneName,
  DateTime? at,
}) {
  return LocationReading(
    latitude: lat,
    longitude: lon,
    timestamp: at ?? DateTime.utc(2030, 1, 1, 12),
    insideSafeZone: inside,
    activeSafeZoneName: zoneName,
  );
}

DeviceCapabilities testCapabilities(
  CommunicationCapability capability, {
  String? citizenPhone,
  String? caregiverPhone,
}) {
  return DeviceCapabilities(
    fragileCitizenId: 'citizen-test',
    wristbandModel: 'Modelo ${capability.name}',
    capability: capability,
    hasCamera: capability == CommunicationCapability.videoAndAudio,
    hasScreen: capability == CommunicationCapability.videoAndAudio,
    hasMicrophone: capability != CommunicationCapability.telemetryOnly,
    hasSpeaker: capability != CommunicationCapability.telemetryOnly,
    supportsHapticAlerts: true,
    supportsTelemetry: true,
    citizenPhone: citizenPhone,
    caregiverPhone: caregiverPhone,
  );
}

CallSession testSession({
  CallType type = CallType.video,
  CallStatus status = CallStatus.active,
  bool degraded = false,
  String? reason,
}) {
  return CallSession(
    callId: 'call-test',
    fragileCitizenId: 'citizen-test',
    callType: type,
    status: status,
    degradedToVoice: degraded,
    degradationReason: reason,
  );
}

class FakeCommunicationRepository implements CommunicationRepository {
  DeviceCapabilities? capabilities;
  Future<CallSession> Function(CallType requested)? onStartCall;
  List<CallLogEntry> logs = [];

  final List<(CallType, int)> unansweredLogged = [];
  final List<String> hapticReasons = [];
  int startCalls = 0;

  @override
  Future<DeviceCapabilities?> getDeviceCapabilities(String fragileCitizenId) async => capabilities;

  @override
  Future<CallSession> startCall(String fragileCitizenId, CallType requestedType) {
    startCalls++;
    return onStartCall!(requestedType);
  }

  @override
  Future<CallSession> endCall(String callId) async => testSession(status: CallStatus.ended);

  @override
  Future<void> logUnanswered(String fragileCitizenId, CallType attemptedType, int timeoutSeconds) async {
    unansweredLogged.add((attemptedType, timeoutSeconds));
  }

  @override
  Future<List<CallLogEntry>> getCallLogs(String fragileCitizenId) async => logs;

  @override
  Future<void> sendHapticAlert(String fragileCitizenId, String reason) async => hapticReasons.add(reason);
}

class FakeSafeZoneRepository implements SafeZoneRepository {
  final List<SafeZone> zones;
  final List<String> deleted = [];

  FakeSafeZoneRepository([List<SafeZone>? zones]) : zones = zones ?? [];

  @override
  Future<List<SafeZone>> getSafeZones(String fragileCitizenId) async => [...zones];

  @override
  Future<SafeZone> create(String fragileCitizenId, SafeZoneDraft draft) async {
    final zone = SafeZone(
      id: 'new-${zones.length}',
      fragileCitizenId: fragileCitizenId,
      name: draft.name,
      latitude: draft.latitude,
      longitude: draft.longitude,
      radiusMeters: draft.radiusMeters,
      isActive: true,
    );
    zones.add(zone);
    return zone;
  }

  @override
  Future<SafeZone> update(String safeZoneId, SafeZoneDraft draft) async {
    final index = zones.indexWhere((zone) => zone.id == safeZoneId);
    zones[index] = zones[index].copyWith(
      name: draft.name,
      latitude: draft.latitude,
      longitude: draft.longitude,
      radiusMeters: draft.radiusMeters,
    );
    return zones[index];
  }

  @override
  Future<void> delete(String safeZoneId) async {
    deleted.add(safeZoneId);
    zones.removeWhere((zone) => zone.id == safeZoneId);
  }

  @override
  Future<void> setActive(String safeZoneId, {required bool active}) async {
    final index = zones.indexWhere((zone) => zone.id == safeZoneId);
    zones[index] = zones[index].copyWith(isActive: active);
  }
}

class FakeLocationTrackingRepository implements LocationTrackingRepository {
  LocationReading? current;
  List<LocationReading> history = [];

  @override
  Future<LocationReading?> getCurrent(String fragileCitizenId) async => current;

  @override
  Future<List<LocationReading>> getHistory(String fragileCitizenId) async => history;

  @override
  Future<MobilityStatus> getStatus(String fragileCitizenId) async =>
      MobilityStatus(isInsideSafeZone: current?.insideSafeZone ?? false, status: 'TEST');
}

/// A start call that never answers, to exercise the timeout.
Future<CallSession> neverAnswers(CallType _) => Completer<CallSession>().future;
