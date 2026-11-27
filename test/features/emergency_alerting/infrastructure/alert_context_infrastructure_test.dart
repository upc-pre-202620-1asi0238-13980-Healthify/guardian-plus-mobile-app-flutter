import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_source_type.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/location/geocoder_place_name_resolver.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/location/place_name_resolver.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/location_tracking_api.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/repositories/alert_context_repository_impl.dart';
import 'package:guardian_plus_app/features/health_monitoring/application/get_live_vital_signs_use_case.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/live_vital_sign.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/live_vital_signs.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/reading_classification.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_reading.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_repository.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_type.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../alert_fakes.dart';

// Shaped like Mobility's LocationResource
const _locationJson = {
  'fragileCitizenId': 'elena',
  'latitude': -12.1211,
  'longitude': -77.0297,
  'accuracyInMeters': 8.5,
  'status': 'INSIDE_SAFE_ZONE',
  'recordedAt': '2026-11-12T14:32:35Z',
};

LiveVitalSign _sign(VitalSignType type, double value, {bool live = true}) {
  return LiveVitalSign(
    id: type.name,
    type: type,
    typeName: type.name,
    unit: '',
    value: value,
    measuredAt: testNow,
    normalMinimum: 0,
    normalMaximum: 0,
    classification: ReadingClassification.withinRange,
    liveSignal: live,
  );
}

class _FakeVitalSignRepository implements VitalSignRepository {
  List<LiveVitalSign> signs = const [];
  bool fails = false;
  final List<String> requested = [];

  @override
  Future<LiveVitalSigns> getLiveVitalSigns(String careRecipientProfileId) async {
    requested.add(careRecipientProfileId);
    if (fails) throw Exception('Health Monitoring is down');
    return LiveVitalSigns(careRecipientProfileId: careRecipientProfileId, retrievedAt: testNow, vitalSigns: signs);
  }

  @override
  Future<List<VitalSignReading>> getVitalSignHistory(
    String careRecipientProfileId, {
    required DateTime from,
    required DateTime to,
  }) async => const [];
}

class _FakePlaceNameResolver implements PlaceNameResolver {
  String? name;

  new([this.name]);

  @override
  Future<String?> nameOf(double latitude, double longitude) async => name;
}

void main() {
  final requests = <http.Request>[];
  late _FakeVitalSignRepository vitals;
  late _FakePlaceNameResolver places;

  LocationTrackingApi answering(Object? body, {int status = 200}) {
    return LocationTrackingApi(
      client: ApiClient(
        baseUrl: 'https://api.test/',
        client: MockClient((request) async {
          requests.add(request);
          return http.Response.bytes(utf8.encode(jsonEncode(body)), status);
        }),
      ),
    );
  }

  AlertContextRepositoryImpl repository(LocationTrackingApi api) {
    return AlertContextRepositoryImpl(
      getLiveVitalSigns: GetLiveVitalSignsUseCase(repository: vitals),
      locationTrackingApi: api,
      placeNameResolver: places,
    );
  }

  setUp(() {
    requests.clear();
    vitals = _FakeVitalSignRepository();
    places = _FakePlaceNameResolver('Av. Larco 345 · Miraflores');
  });

  test('an SOS gets the live heart rate and SpO2 and the named place of the last position', () async {
    vitals.signs = [_sign(VitalSignType.hr, 111.6), _sign(VitalSignType.spo2, 95), _sign(VitalSignType.temp, 36.6)];

    final context = await repository(answering(_locationJson))
        .getAlertContext(alert('sos', source: AlertSourceType.sosTriggered));

    expect(requests.single.url.path, '/location-tracking/elena/current');
    expect(vitals.requested, ['elena']);
    expect(context.heartRateBpm, 112);
    expect(context.oxygenSaturation, 95);
    expect(context.locationName, 'Av. Larco 345 · Miraflores');
    expect(context.locationUpdatedAt, DateTime.utc(2026, 11, 12, 14, 32, 35));
  });

  test('a reading older than the live window is left out', () async {
    vitals.signs = [_sign(VitalSignType.hr, 80, live: false), _sign(VitalSignType.spo2, 97)];

    final context = await repository(answering(_locationJson)).getAlertContext(alert('fall'));

    expect(context.heartRateBpm, isNull);
    expect(context.oxygenSaturation, 97);
  });

  test('without a place name the coordinates are shown', () async {
    places.name = null;

    final context = await repository(answering(_locationJson)).getAlertContext(alert('fall'));

    expect(context.locationName, '-12.12110, -77.02970');
  });

  test('no position yet (404) or no readings still give the rest of the context', () async {
    vitals.fails = true;

    final context = await repository(answering({'message': 'Location not found'}, status: 404))
        .getAlertContext(alert('fall'));

    expect(context.locationName, isNull);
    expect(context.hasVitals, isFalse);
  });

  test('each source only asks for what it needs', () async {
    final api = answering(_locationJson);

    final anomaly = await repository(api).getAlertContext(alert('hr', source: AlertSourceType.vitalSignAnomaly));
    expect(requests, isEmpty);
    expect(anomaly.locationName, isNull);

    await repository(api).getAlertContext(alert('zone', source: AlertSourceType.safeZoneViolation));
    expect(requests, hasLength(1));
    expect(vitals.requested, ['elena']);

    await repository(api).getAlertContext(alert('pill', source: AlertSourceType.medicationRestockSuggested));
    expect(requests, hasLength(1));
    expect(vitals.requested, ['elena']);
  });

  test('a place reads street first, then the district', () {
    expect(
      placeNameOf(Placemark(thoroughfare: 'Av. Larco', subThoroughfare: '345', subLocality: 'Miraflores')),
      'Av. Larco 345 · Miraflores',
    );
    expect(placeNameOf(Placemark(name: 'Parque Kennedy', locality: 'Lima')), 'Parque Kennedy · Lima');
    expect(placeNameOf(Placemark(locality: 'Lima', subLocality: '')), 'Lima');
    expect(placeNameOf(Placemark()), isNull);
  });
}
