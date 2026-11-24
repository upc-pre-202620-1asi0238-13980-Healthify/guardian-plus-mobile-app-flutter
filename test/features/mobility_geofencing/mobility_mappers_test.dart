import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/communication.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/safe_zone.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/infrastructure/remote/mobility_mappers.dart';

// Payloads follow components.schemas of docs/api_contract_mobility.md
void main() {
  test('CurrentLocationResource: ints become doubles and the status tells if it is inside the zone', () {
    final reading = locationReadingFromJson({
      'fragileCitizenId': 'c',
      'latitude': 10,
      'longitude': 20.5,
      'accuracyInMeters': 12,
      'status': 'WITHIN_SAFE_ZONE',
      'recordedAt': '2030-01-01T12:00:00Z',
    });

    expect(reading.latitude, 10.0);
    expect(reading.longitude, 20.5);
    expect(reading.accuracy, 12.0);
    expect(reading.insideSafeZone, isTrue);
    expect(reading.timestamp, DateTime.utc(2030, 1, 1, 12));

    final outside = locationReadingFromJson({
      'latitude': 1.0,
      'longitude': 2.0,
      'status': 'OUTSIDE_SAFE_ZONE',
      'recordedAt': '2030-01-01T12:00:00Z',
    });
    expect(outside.insideSafeZone, isFalse);
    expect(outside.accuracy, isNull);
  });

  test('rejects a reading without coordinates instead of inventing them', () {
    expect(() => locationReadingFromJson({'recordedAt': '2030-01-01T12:00:00Z'}), throwsFormatException);
  });

  test('LocationStatusResource: reads the three statuses', () {
    expect(mobilityStatusFromJson({'fragileCitizenId': 'c', 'status': 'WITHIN_SAFE_ZONE'}).isInsideSafeZone, isTrue);
    expect(mobilityStatusFromJson({'fragileCitizenId': 'c', 'status': 'OUTSIDE_SAFE_ZONE'}).isInsideSafeZone, isFalse);
    final unknown = mobilityStatusFromJson({'fragileCitizenId': 'c', 'status': 'UNKNOWN'});
    expect(unknown.isInsideSafeZone, isFalse);
    expect(unknown.status, 'UNKNOWN');
  });

  test('SafeZoneResource and the create/update bodies use centerLatitude, centerLongitude and radiusInMeters', () {
    final zone = safeZoneFromJson({
      'id': 'z',
      'fragileCitizenId': 'c',
      'name': 'Zona',
      'latitude': 1.5,
      'longitude': 2.5,
      'radiusInMeters': 150,
      'status': 'ACTIVE',
    });
    expect(zone.latitude, 1.5);
    expect(zone.radiusMeters, 150.0);
    expect(zone.isActive, isTrue);
    expect(
      safeZoneFromJson({
        'id': 'z',
        'fragileCitizenId': 'c',
        'name': 'Zona',
        'latitude': 1.5,
        'longitude': 2.5,
        'radiusInMeters': 150,
        'status': 'INACTIVE',
      }).isActive,
      isFalse,
    );

    const draft = SafeZoneDraft(name: 'Zona', latitude: 1.5, longitude: 2.5, radiusMeters: 150);
    expect(createSafeZoneToJson('c', draft), {
      'fragileCitizenId': 'c',
      'name': 'Zona',
      'centerLatitude': 1.5,
      'centerLongitude': 2.5,
      'radiusInMeters': 150.0,
    });
    expect(updateSafeZoneToJson(draft), {
      'name': 'Zona',
      'centerLatitude': 1.5,
      'centerLongitude': 2.5,
      'radiusInMeters': 150.0,
    });
  });

  test('DeviceCapabilitiesResource: the capability is derived from the hardware, blank phones become null', () {
    final video = deviceCapabilitiesFromJson({
      'fragileCitizenId': 'c',
      'wristbandModel': 'Guardian Pro',
      'hasCamera': true,
      'hasScreen': true,
      'hasMicrophone': true,
      'hasSpeaker': true,
      'supportsHapticAlerts': true,
      'supportsTelemetry': true,
      'citizenPhone': '  ',
      'caregiverPhone': '123',
    });
    expect(video.capability, CommunicationCapability.videoAndAudio);
    expect(video.supportsVideo, isTrue);
    expect(video.citizenPhone, isNull);
    expect(video.caregiverPhone, '123');

    final audio = deviceCapabilitiesFromJson({
      'fragileCitizenId': 'c',
      'hasCamera': false,
      'hasScreen': false,
      'hasMicrophone': true,
      'hasSpeaker': true,
    });
    expect(audio.capability, CommunicationCapability.audioOnly);
    expect(audio.supportsVoice, isTrue);
    expect(audio.supportsVideo, isFalse);

    final telemetry = deviceCapabilitiesFromJson({'fragileCitizenId': 'c', 'supportsTelemetry': true});
    expect(telemetry.capability, CommunicationCapability.telemetryOnly);
  });

  test('CallSessionResource and CallLogEntryResource', () {
    final session = callSessionFromJson({
      'callId': 'k',
      'fragileCitizenId': 'c',
      'activeType': 'VOICE',
      'status': 'ACTIVE',
      'downgraded': true,
      'reasonMessage': 'sin cámara',
      'startedAt': '2030-01-01T12:00:00Z',
    });
    expect(session.callType, CallType.voice);
    expect(session.status, CallStatus.active);
    expect(session.degradedToVoice, isTrue);
    expect(session.degradationReason, 'sin cámara');

    final log = callLogFromJson({
      'id': 'l',
      'fragileCitizenId': 'c',
      'callType': 'VIDEO',
      'status': 'UNANSWERED',
      'downgraded': false,
      'reason': 'Sin respuesta',
      'durationSeconds': 0,
      'occurredAt': '2030-01-01T12:00:00Z',
    });
    expect(log.status, CallStatus.unanswered);
    expect(log.callType, CallType.video);
    expect(log.notes, 'Sin respuesta');
    expect(log.timestamp, DateTime.utc(2030, 1, 1, 12));
  });

  test('request bodies of the communication endpoints', () {
    expect(startCallToJson('c', CallType.video), {'fragileCitizenId': 'c', 'requestedType': 'VIDEO'});
    expect(
      logUnansweredToJson('c', CallType.voice, 'r'),
      {'fragileCitizenId': 'c', 'attemptedType': 'VOICE', 'reason': 'r'},
    );
    expect(hapticAlertToJson('c', 'm'), {'fragileCitizenId': 'c', 'message': 'm'});
  });
}
