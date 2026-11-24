import 'package:guardian_plus_app/features/mobility_geofencing/domain/communication.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/location_reading.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/safe_zone.dart';

/// JSON <-> domain mappers of the mobility_geofencing REST contract.

double? _optionalDouble(Object? value) => value is num ? value.toDouble() : null;

double _requiredDouble(Object? value, String field) {
  if (value is num) return value.toDouble();
  throw FormatException('Missing numeric field "$field"');
}

String _requiredString(Object? value, String field) {
  if (value == null) throw FormatException('Missing field "$field"');
  return value.toString();
}

DateTime? _optionalDate(Object? value) => value is String ? DateTime.tryParse(value) : null;

int? _optionalInt(Object? value) => value is num ? value.toInt() : null;

/// Wire values of `LocationStatusResource.status` / `CurrentLocationResource.status`.
const _withinSafeZone = 'WITHIN_SAFE_ZONE';

/// Wire value of `SafeZoneResource.status` for the zone being monitored.
const _activeZoneStatus = 'ACTIVE';

/// `CurrentLocationResource` and the items of `LocationHistoryResource`.
LocationReading locationReadingFromJson(Map<String, dynamic> json) {
  return LocationReading(
    latitude: _requiredDouble(json['latitude'], 'latitude'),
    longitude: _requiredDouble(json['longitude'], 'longitude'),
    accuracy: _optionalDouble(json['accuracyInMeters']),
    timestamp: _optionalDate(json['recordedAt']) ?? (throw const FormatException('Missing field "recordedAt"')),
    insideSafeZone: json['status'] == _withinSafeZone,
  );
}

/// `LocationStatusResource`.
MobilityStatus mobilityStatusFromJson(Map<String, dynamic> json) {
  final status = json['status']?.toString() ?? '';
  return MobilityStatus(isInsideSafeZone: status == _withinSafeZone, status: status);
}

/// `SafeZoneResource`.
SafeZone safeZoneFromJson(Map<String, dynamic> json) {
  return SafeZone(
    id: _requiredString(json['id'], 'id'),
    fragileCitizenId: _requiredString(json['fragileCitizenId'], 'fragileCitizenId'),
    name: _requiredString(json['name'], 'name'),
    latitude: _requiredDouble(json['latitude'], 'latitude'),
    longitude: _requiredDouble(json['longitude'], 'longitude'),
    radiusMeters: _requiredDouble(json['radiusInMeters'], 'radiusInMeters'),
    isActive: json['status']?.toString().toUpperCase() == _activeZoneStatus,
  );
}

/// `CreateSafeZoneResource`.
Map<String, dynamic> createSafeZoneToJson(String fragileCitizenId, SafeZoneDraft draft) {
  return {'fragileCitizenId': fragileCitizenId, ...updateSafeZoneToJson(draft)};
}

/// `UpdateSafeZoneResource`.
Map<String, dynamic> updateSafeZoneToJson(SafeZoneDraft draft) {
  return {
    'name': draft.name,
    'centerLatitude': draft.latitude,
    'centerLongitude': draft.longitude,
    'radiusInMeters': draft.radiusMeters,
  };
}

/// `DeviceCapabilitiesResource`. The platform sends no summary, so it is derived from the hardware flags: video
/// needs camera, screen, microphone and speaker; voice needs microphone and speaker; otherwise telemetry only.
DeviceCapabilities deviceCapabilitiesFromJson(Map<String, dynamic> json) {
  final hasCamera = json['hasCamera'] == true;
  final hasScreen = json['hasScreen'] == true;
  final hasMicrophone = json['hasMicrophone'] == true;
  final hasSpeaker = json['hasSpeaker'] == true;
  final capability = hasCamera && hasScreen && hasMicrophone && hasSpeaker
      ? CommunicationCapability.videoAndAudio
      : hasMicrophone && hasSpeaker
          ? CommunicationCapability.audioOnly
          : CommunicationCapability.telemetryOnly;
  return DeviceCapabilities(
    fragileCitizenId: _requiredString(json['fragileCitizenId'], 'fragileCitizenId'),
    wristbandModel: json['wristbandModel'] as String?,
    capability: capability,
    hasCamera: hasCamera,
    hasScreen: hasScreen,
    hasMicrophone: hasMicrophone,
    hasSpeaker: hasSpeaker,
    supportsHapticAlerts: json['supportsHapticAlerts'] == true,
    supportsTelemetry: json['supportsTelemetry'] == true,
    citizenPhone: _blankToNull(json['citizenPhone']),
    caregiverPhone: _blankToNull(json['caregiverPhone']),
  );
}

String? _blankToNull(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

/// `CallSessionResource`.
CallSession callSessionFromJson(Map<String, dynamic> json) {
  return CallSession(
    callId: _requiredString(json['callId'], 'callId'),
    fragileCitizenId: _requiredString(json['fragileCitizenId'], 'fragileCitizenId'),
    callType: CallType.fromWire(json['activeType'] as String?),
    status: CallStatus.fromWire(json['status'] as String?),
    degradedToVoice: json['downgraded'] == true,
    degradationReason: _blankToNull(json['reasonMessage']),
    startedAt: _optionalDate(json['startedAt']),
  );
}

/// `CallLogEntryResource`.
CallLogEntry callLogFromJson(Map<String, dynamic> json) {
  return CallLogEntry(
    id: _requiredString(json['id'], 'id'),
    fragileCitizenId: _requiredString(json['fragileCitizenId'], 'fragileCitizenId'),
    callType: CallType.fromWire(json['callType'] as String?),
    status: CallStatus.fromWire(json['status'] as String?),
    durationSeconds: _optionalInt(json['durationSeconds']),
    timestamp: _optionalDate(json['occurredAt']),
    notes: _blankToNull(json['reason']),
  );
}

/// `StartCallRequestResource`.
Map<String, dynamic> startCallToJson(String fragileCitizenId, CallType requestedType) {
  return {'fragileCitizenId': fragileCitizenId, 'requestedType': requestedType.wire};
}

/// `RegisterCallLogRequestResource`.
Map<String, dynamic> logUnansweredToJson(String fragileCitizenId, CallType attemptedType, String reason) {
  return {'fragileCitizenId': fragileCitizenId, 'attemptedType': attemptedType.wire, 'reason': reason};
}

/// `HapticAlertRequestResource`.
Map<String, dynamic> hapticAlertToJson(String fragileCitizenId, String message) {
  return {'fragileCitizenId': fragileCitizenId, 'message': message};
}
