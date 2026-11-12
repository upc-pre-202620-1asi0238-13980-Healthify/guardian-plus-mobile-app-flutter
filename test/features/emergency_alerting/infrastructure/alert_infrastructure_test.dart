import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_source_type.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/delivery_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/notification_channel.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/recipient_level.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/response_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/severity.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/mappers/api_enum_mapper.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_api.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/incident_api.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/repositories/alert_repository_impl.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/repositories/incident_repository_impl.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// Shaped like the platform's AlertResource
const _alertJson = {
  'id': 'a1',
  'careRecipientProfileId': 'elena',
  'sourceType': 'FALL_DETECTED',
  'sourceReferenceId': 'r1',
  'severity': 'CRITICAL',
  'status': 'ESCALATED',
  'currentRecipientLevel': 'SECONDARY',
  'triggeredAt': '2026-11-12T14:30:00.123456Z',
  'confirmedAt': '2026-11-12T14:30:20Z',
  'lastDispatchedAt': '2026-11-12T14:31:20Z',
  'acknowledgedAt': null,
  'acknowledgedByUserId': null,
  'resolvedAt': null,
  'deliveries': [
    {
      'id': 'd1',
      'recipientUserId': 'maria',
      'recipientLevel': 'PRIMARY',
      'channel': 'IN_APP',
      'deliveryStatus': 'DELIVERED',
      'sentAt': '2026-11-12T14:30:20Z',
      'deliveredAt': '2026-11-12T14:30:21Z',
    },
  ],
  'responses': [
    {
      'id': 'r1',
      'responderUserId': 'carlos',
      'responseStatus': 'CLAIMED',
      'claimedAt': '2026-11-12T14:32:00Z',
      'completedAt': null,
      'notes': null,
    },
  ],
};

void main() {
  final requests = <http.Request>[];

  ApiClient answering(Object? body, {int status = 200}) {
    return ApiClient(
      baseUrl: 'https://api.test/',
      client: MockClient((request) async {
        requests.add(request);
        return http.Response.bytes(utf8.encode(jsonEncode(body)), status);
      }),
    );
  }

  setUp(requests.clear);

  test('maps a full alert, with its deliveries and responses, from the platform names', () async {
    final repository = AlertRepositoryImpl(api: AlertApi(client: answering(_alertJson)));

    final alert = await repository.getAlertById('a1');

    expect(requests.single.url.path, '/alerts/a1');
    expect(alert.sourceType, AlertSourceType.fallDetected);
    expect(alert.severity, Severity.critical);
    expect(alert.status, AlertStatus.escalated);
    expect(alert.currentRecipientLevel, RecipientLevel.secondary);
    expect(alert.triggeredAt, DateTime.utc(2026, 11, 12, 14, 30, 0, 123, 456));
    expect(alert.acknowledgedAt, isNull);
    expect(alert.deliveries.single.channel, NotificationChannel.inApp);
    expect(alert.deliveries.single.status, DeliveryStatus.delivered);
    expect(alert.responses.single.status, ResponseStatus.claimed);
    expect(alert.activeResponse?.responderUserId, 'carlos');
  });

  test('the history sends only the filters that are set, with the names the platform expects', () async {
    final repository = AlertRepositoryImpl(
      api: AlertApi(client: answering({'content': [], 'page': 0, 'size': 20, 'totalElements': 0, 'totalPages': 0})),
    );

    await repository.getAlertHistory(careRecipientProfileId: 'elena', page: 0, size: 20);
    await repository.getAlertHistory(
      careRecipientProfileId: 'elena',
      severity: Severity.critical,
      from: DateTime.utc(2026, 11, 5, 12),
      page: 2,
      size: 100,
    );

    expect(requests[0].url.queryParameters, {'careRecipientProfileId': 'elena', 'page': '0', 'size': '20'});
    expect(requests[1].url.queryParameters, {
      'careRecipientProfileId': 'elena',
      'severity': 'CRITICAL',
      'from': '2026-11-05T12:00:00.000Z',
      'page': '2',
      'size': '100',
    });
  });

  test('acknowledging sends who did it', () async {
    final repository = AlertRepositoryImpl(api: AlertApi(client: answering(_alertJson)));

    await repository.acknowledgeAlert(alertId: 'a1', userId: 'maria');

    expect(requests.single.method, 'POST');
    expect(requests.single.url.path, '/alerts/a1/acknowledge');
    expect(jsonDecode(requests.single.body), {'userId': 'maria'});
  });

  group('IncidentRepositoryImpl', () {
    test('an alert nobody acknowledged has no incident (404)', () async {
      final repository = IncidentRepositoryImpl(
        api: IncidentApi(client: answering({'message': 'Incident not found'}, status: 404)),
      );

      expect(await repository.getIncidentByAlertId('a1'), isNull);
    });

    test('any other failure is reported', () async {
      final repository = IncidentRepositoryImpl(
        api: IncidentApi(client: answering({'message': 'Error interno'}, status: 500)),
      );

      expect(repository.getIncidentByAlertId('a1'), throwsA(isA<ApiException>()));
    });

    test('closing sends the notes and maps the closed incident', () async {
      final repository = IncidentRepositoryImpl(
        api: IncidentApi(
          client: answering({
            'id': 'i1',
            'alertId': 'a1',
            'status': 'CLOSED',
            'markedInAttentionAt': '2026-11-12T14:31:00Z',
            'stabilizedAt': null,
            'closedAt': '2026-11-12T14:40:00Z',
            'notes': 'Sin lesiones',
          }),
        ),
      );

      final incident = await repository.closeIncident(incidentId: 'i1', notes: 'Sin lesiones');

      expect(requests.single.url.path, '/incidents/i1/close');
      expect(jsonDecode(requests.single.body), {'notes': 'Sin lesiones'});
      expect(incident.status, IncidentStatus.closed);
      expect(incident.closedAt, DateTime.utc(2026, 11, 12, 14, 40));
    });
  });

  test('enum names convert both ways and an unknown one is a contract error', () {
    expect(
      enumFromApi(AlertSourceType.values, 'MEDICATION_RESTOCK_SUGGESTED'),
      AlertSourceType.medicationRestockSuggested,
    );
    expect(enumToApi(AlertStatus.pendingConfirmation), 'PENDING_CONFIRMATION');
    expect(() => enumFromApi(Severity.values, 'LOW'), throwsFormatException);
  });
}
