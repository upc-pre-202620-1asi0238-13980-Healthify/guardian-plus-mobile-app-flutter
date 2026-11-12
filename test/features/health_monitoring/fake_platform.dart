import 'dart:convert';

import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/health_monitoring/health_monitoring_dependencies.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const careRecipientId = 'elena';

/// The Health Monitoring endpoints of the platform, answered from memory, so the tests go through the real
/// ApiClient, APIs, mappers, repositories, use cases and view models.
class FakePlatform {
  double heartRate = 78;
  double systolic = 118;
  bool platformDown = false;
  final List<Map<String, dynamic>> wearables = [];
  final List<Map<String, dynamic>> history = [];
  final List<http.Request> requests = [];

  /// Registers Health Monitoring in the app's service locator, talking to this platform.
  void install() {
    getIt
      ..registerSingleton<ApiClient>(ApiClient(client: MockClient(_answer), baseUrl: 'https://api.test/api/v1/'))
      ..registerSingleton<CareContextStore>(
        CareContextStore()..save(const CareContext(
          userAccountId: 'maria',
          userFullName: 'María Rojas',
          careRecipientProfileId: careRecipientId,
          careRecipientName: 'Elena Rojas',
        )),
      );
    setupHealthMonitoring(getIt);
  }

  void addReading(String type, double value, DateTime at) {
    history.add({
      'id': 'r${history.length}',
      'vitalSignType': type,
      'value': value,
      'measuredAt': at.toUtc().toIso8601String(),
    });
  }

  Future<http.Response> _answer(http.Request request) async {
    requests.add(request);
    if (platformDown) return _json({'message': 'Servicio no disponible'}, 503);
    final path = request.url.path.replaceFirst('/api/v1/', '');
    return switch ((request.method, path)) {
      ('GET', 'vital-signs/live/$careRecipientId') => _json(_live()),
      ('GET', 'vital-signs/history/$careRecipientId') => _json(history),
      ('GET', 'wearable-devices/care-recipient/$careRecipientId') => _json(wearables),
      ('POST', 'wearable-devices') => _link(jsonDecode(request.body)),
      _ => _json({'message': 'Not found'}, 404),
    };
  }

  http.Response _link(Map<String, dynamic> body) {
    if (wearables.any((device) => device['serialNumber'] == body['serialNumber'])) {
      return _json({'message': 'El número de serie ya está vinculado'}, 409);
    }
    final device = {...body, 'id': 'w${wearables.length}', 'linkedAt': DateTime.now().toUtc().toIso8601String()};
    wearables.add(device);
    return _json(device, 201);
  }

  Map<String, dynamic> _live() {
    final measuredAt = DateTime.now().subtract(const Duration(minutes: 1)).toUtc().toIso8601String();
    Map<String, dynamic> sign(String type, double value, double min, double max) => {
      'vitalSignId': type,
      'vitalSignType': type,
      'vitalSignTypeName': type,
      'unit': '',
      'value': value,
      'measuredAt': measuredAt,
      'normalMinimum': min,
      'normalMaximum': max,
      'classification': value < min ? 'BELOW_RANGE' : (value > max ? 'ABOVE_RANGE' : 'WITHIN_RANGE'),
      'liveSignal': true,
    };
    return {
      'careRecipientProfileId': careRecipientId,
      'retrievedAt': DateTime.now().subtract(const Duration(minutes: 2)).toUtc().toIso8601String(),
      'vitalSigns': [
        sign('HR', heartRate, 60, 100),
        sign('BP_SYS', systolic, 90, 140),
        sign('BP_DIA', 76, 60, 90),
        sign('SPO2', 98, 92, 100),
        sign('TEMP', 36.6, 36, 37.5),
        sign('RESP_RATE', 16, 12, 20),
      ],
    };
  }

  static http.Response _json(Object body, [int status = 200]) =>
      http.Response.bytes(utf8.encode(jsonEncode(body)), status, headers: {'content-type': 'application/json'});
}
