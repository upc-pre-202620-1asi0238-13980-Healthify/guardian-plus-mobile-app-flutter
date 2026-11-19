import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/communication.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/safe_zone.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/infrastructure/remote/mobility_mappers.dart';

void main() {
  test('maps a location reading, with ints as doubles and optional fields missing', () {
    final reading = locationReadingFromJson({
      'latitude': 10,
      'longitude': 20.5,
      'timestamp': '2030-01-01T12:00:00Z',
      'insideSafeZone': true,
      'activeSafeZoneId': 7,
      'activeSafeZoneName': 'Zona',
    });

    expect(reading.latitude, 10.0);
    expect(reading.longitude, 20.5);
    expect(reading.accuracy, isNull);
    expect(reading.insideSafeZone, isTrue);
    expect(reading.activeSafeZoneId, '7');
    expect(reading.timestamp, DateTime.utc(2030, 1, 1, 12));
  });

  test('rejects a reading without coordinates instead of inventing them', () {
    expect(() => locationReadingFromJson({'timestamp': '2030-01-01T12:00:00Z'}), throwsFormatException);
  });

  test('maps a safe zone and builds the create/update bodies', () {
    final zone = safeZoneFromJson({
      'id': 'z',
      'fragileCitizenId': 'c',
      'name': 'Zona',
      'latitude': 1.5,
      'longitude': 2.5,
      'radiusMeters': 150,
      'isActive': true,
    });
    expect(zone.radiusMeters, 150.0);
    expect(zone.isActive, isTrue);

    const draft = SafeZoneDraft(name: 'Zona', latitude: 1.5, longitude: 2.5, radiusMeters: 150);
    expect(createSafeZoneToJson('c', draft), {
      'fragileCitizenId': 'c',
      'name': 'Zona',
      'latitude': 1.5,
      'longitude': 2.5,
      'radiusMeters': 150.0,
    });
    expect(updateSafeZoneToJson(draft).containsKey('fragileCitizenId'), isFalse);
  });

  test('maps device capabilities, blank phones become null and unknown capability is telemetry only', () {
    final capabilities = deviceCapabilitiesFromJson({
      'fragileCitizenId': 'c',
      'capability': 'AUDIO_ONLY',
      'hasMicrophone': true,
      'citizenPhone': '  ',
      'caregiverPhone': '123',
    });
    expect(capabilities.capability, CommunicationCapability.audioOnly);
    expect(capabilities.supportsVoice, isTrue);
    expect(capabilities.supportsVideo, isFalse);
    expect(capabilities.citizenPhone, isNull);
    expect(capabilities.caregiverPhone, '123');

    expect(
      deviceCapabilitiesFromJson({'fragileCitizenId': 'c', 'capability': 'SOMETHING_NEW'}).capability,
      CommunicationCapability.telemetryOnly,
    );
  });

  test('maps a call session and a call log entry', () {
    final session = callSessionFromJson({
      'callId': 'k',
      'fragileCitizenId': 'c',
      'callType': 'VOICE',
      'status': 'ACTIVE',
      'degradedToVoice': true,
      'degradationReason': 'sin cámara',
      'startedAt': '2030-01-01T12:00:00Z',
    });
    expect(session.callType, CallType.voice);
    expect(session.status, CallStatus.active);
    expect(session.degradedToVoice, isTrue);

    final log = callLogFromJson({
      'id': 'l',
      'fragileCitizenId': 'c',
      'callType': 'VIDEO',
      'status': 'UNANSWERED',
      'durationSeconds': 0,
      'timestamp': '2030-01-01T12:00:00Z',
    });
    expect(log.status, CallStatus.unanswered);
    expect(log.callType, CallType.video);
  });
}
