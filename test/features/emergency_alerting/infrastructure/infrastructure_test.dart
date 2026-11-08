import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/notification_channel.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_channel_setting_api.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_settings_api.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/emergency_contact_api.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/repositories/alert_channel_setting_repository_impl.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/repositories/alert_settings_repository_impl.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/repositories/emergency_contact_repository_impl.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _contactJson = {
  'id': 'c1',
  'careRecipientProfileId': 'elena',
  'userId': 'maria',
  'displayName': 'María Rojas',
  'relationship': 'Hija',
  'phoneNumber': '+51987654321',
  'priorityOrder': 1,
  'active': true,
};

const _settingsJson = {
  'careRecipientProfileId': 'elena',
  'primaryAckTimeoutSec': 60,
  'escalationEnabled': true,
  'silentModeEnabled': true,
  'broadcastCriticalImmediately': false,
};

void main() {
  final requests = <http.Request>[];

  ApiClient answering(Object body) {
    return ApiClient(
      baseUrl: 'https://api.test/',
      client: MockClient((request) async {
        requests.add(request);
        return http.Response.bytes(utf8.encode(jsonEncode(body)), 200);
      }),
    );
  }

  setUp(requests.clear);

  group('EmergencyContactRepositoryImpl', () {
    test('reads the contacts of the person under care', () async {
      final repository = EmergencyContactRepositoryImpl(api: EmergencyContactApi(client: answering([_contactJson])));

      final contacts = await repository.getEmergencyContacts('elena');

      expect(requests.single.url.path, '/emergency-contacts/care-recipient/elena');
      expect(contacts.single.displayName, 'María Rojas');
      expect(contacts.single.priorityOrder, 1);
    });

    test('sends the new order with the field name the platform expects', () async {
      final repository = EmergencyContactRepositoryImpl(api: EmergencyContactApi(client: answering([_contactJson])));

      await repository.reorderEmergencyContacts(careRecipientProfileId: 'elena', orderedIds: ['c2', 'c1']);

      expect(requests.single.method, 'PUT');
      expect(requests.single.url.path, '/emergency-contacts/care-recipient/elena/order');
      expect(jsonDecode(requests.single.body), {
        'orderedEmergencyContactIds': ['c2', 'c1'],
      });
    });
  });

  group('AlertSettingsRepositoryImpl', () {
    test('turns silent mode on by creating the resource and off by deleting it', () async {
      final repository = AlertSettingsRepositoryImpl(api: AlertSettingsApi(client: answering(_settingsJson)));

      final settings = await repository.setSilentMode(careRecipientProfileId: 'elena', enabled: true);
      await repository.setSilentMode(careRecipientProfileId: 'elena', enabled: false);

      expect(requests.map((request) => request.method), ['POST', 'DELETE']);
      expect(requests.first.url.path, '/alert-settings/care-recipient/elena/silent-mode');
      expect(settings.silentModeEnabled, isTrue);
      expect(settings.broadcastCriticalImmediately, isFalse);
    });
  });

  group('AlertChannelSettingRepositoryImpl', () {
    test('maps the channel names of the platform both ways', () async {
      final repository = AlertChannelSettingRepositoryImpl(
        api: AlertChannelSettingApi(
          client: answering({'userId': 'maria', 'channel': 'IN_APP', 'enabled': false, 'deviceTokenRegistered': false}),
        ),
      );

      final saved = await repository.configureChannel(
        userId: 'maria',
        channel: NotificationChannel.inApp,
        enabled: false,
      );

      expect(requests.single.url.path, '/alert-channel-settings/user/maria/channels/IN_APP');
      expect(jsonDecode(requests.single.body), {'enabled': false});
      expect(saved.channel, NotificationChannel.inApp);
      expect(saved.enabled, isFalse);
    });
  });
}
