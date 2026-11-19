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

LocationReading locationReadingFromJson(Map<String, dynamic> json) {
  return LocationReading(
    latitude: _requiredDouble(json['latitude'], 'latitude'),
    longitude: _requiredDouble(json['longitude'], 'longitude'),
    accuracy: _optionalDouble(json['accuracy']),
    speed: _optionalDouble(json['speed']),
    timestamp: _optionalDate(json['timestamp']) ?? (throw const FormatException('Missing field "timestamp"')),
    insideSafeZone: json['insideSafeZone'] == true,
    activeSafeZoneId: json['activeSafeZoneId']?.toString(),
    activeSafeZoneName: json['activeSafeZoneName'] as String?,
  );
}

MobilityStatus mobilityStatusFromJson(Map<String, dynamic> json) {
  return MobilityStatus(
    isInsideSafeZone: json['isInsideSafeZone'] == true,
    status: json['status']?.toString() ?? '',
    lastUpdated: _optionalDate(json['lastUpdated']),
    currentSafeZoneName: json['currentSafeZoneName'] as String?,
  );
}

SafeZone safeZoneFromJson(Map<String, dynamic> json) {
  return SafeZone(
    id: _requiredString(json['id'], 'id'),
    fragileCitizenId: _requiredString(json['fragileCitizenId'], 'fragileCitizenId'),
    name: _requiredString(json['name'], 'name'),
    latitude: _requiredDouble(json['latitude'], 'latitude'),
    longitude: _requiredDouble(json['longitude'], 'longitude'),
    radiusMeters: _requiredDouble(json['radiusMeters'], 'radiusMeters'),
    isActive: json['isActive'] == true || json['active'] == true,
  );
}

Map<String, dynamic> createSafeZoneToJson(String fragileCitizenId, SafeZoneDraft draft) {
  return {'fragileCitizenId': fragileCitizenId, ...updateSafeZoneToJson(draft)};
}

Map<String, dynamic> updateSafeZoneToJson(SafeZoneDraft draft) {
  return {
    'name': draft.name,
    'latitude': draft.latitude,
    'longitude': draft.longitude,
    'radiusMeters': draft.radiusMeters,
  };
}

DeviceCapabilities deviceCapabilitiesFromJson(Map<String, dynamic> json) {
  return DeviceCapabilities(
    fragileCitizenId: _requiredString(json['fragileCitizenId'], 'fragileCitizenId'),
    wristbandModel: json['wristbandModel'] as String?,
    capability: CommunicationCapability.fromWire(json['capability'] as String?),
    hasCamera: json['hasCamera'] == true,
    hasScreen: json['hasScreen'] == true,
    hasMicrophone: json['hasMicrophone'] == true,
    hasSpeaker: json['hasSpeaker'] == true,
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

CallSession callSessionFromJson(Map<String, dynamic> json) {
  return CallSession(
    callId: _requiredString(json['callId'], 'callId'),
    fragileCitizenId: _requiredString(json['fragileCitizenId'], 'fragileCitizenId'),
    callType: CallType.fromWire(json['callType'] as String?),
    status: CallStatus.fromWire(json['status'] as String?),
    degradedToVoice: json['degradedToVoice'] == true,
    degradationReason: json['degradationReason'] as String?,
    startedAt: _optionalDate(json['startedAt']),
    durationSeconds: _optionalInt(json['durationSeconds']),
    citizenPhone: _blankToNull(json['citizenPhone']),
    caregiverPhone: _blankToNull(json['caregiverPhone']),
  );
}

CallLogEntry callLogFromJson(Map<String, dynamic> json) {
  return CallLogEntry(
    id: _requiredString(json['id'], 'id'),
    fragileCitizenId: _requiredString(json['fragileCitizenId'], 'fragileCitizenId'),
    callType: CallType.fromWire(json['callType'] as String?),
    status: CallStatus.fromWire(json['status'] as String?),
    durationSeconds: _optionalInt(json['durationSeconds']),
    timestamp: _optionalDate(json['timestamp']),
    notes: json['notes'] as String?,
  );
}
