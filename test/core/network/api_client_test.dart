import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  ApiClient clientAnswering(Future<http.Response> Function(http.Request request) handler) {
    return ApiClient(client: MockClient(handler), baseUrl: 'https://api.test/api/v1/');
  }

  test('decodes the body as UTF-8 even without a charset', () async {
    final client = clientAnswering((request) async {
      return http.Response.bytes(utf8.encode('{"displayName":"María Peña"}'), 200);
    });

    final json = await client.get('emergency-contacts/1');

    expect(json['displayName'], 'María Peña');
  });

  test('sends the path under the base URL and the body as JSON', () async {
    late http.Request sent;
    final client = clientAnswering((request) async {
      sent = request;
      return http.Response('{}', 200);
    });

    await client.put('alert-settings/care-recipient/42', body: {'escalationEnabled': true});

    expect(sent.method, 'PUT');
    expect(sent.url.toString(), 'https://api.test/api/v1/alert-settings/care-recipient/42');
    expect(sent.headers['Content-Type'], startsWith('application/json'));
    expect(jsonDecode(sent.body), {'escalationEnabled': true});
    expect(sent.headers['Accept-Language'], isNotEmpty);
  });

  test('a rejected request carries the message of the platform', () async {
    final client = clientAnswering((request) async {
      return http.Response.bytes(
        utf8.encode('{"code":"LAST_CONTACT","message":"Debe quedar al menos un contacto"}'),
        422,
      );
    });

    expect(
      client.delete('emergency-contacts/1'),
      throwsA(isA<ApiException>()
          .having((e) => e.message, 'message', 'Debe quedar al menos un contacto')
          .having((e) => e.statusCode, 'statusCode', 422)),
    );
  });

  test('a rejected request without a JSON body says the status code', () async {
    final client = clientAnswering((request) async => http.Response('Bad gateway', 502));

    expect(
      client.get('alert-settings/care-recipient/1'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', 'El servidor respondió con el código 502')),
    );
  });

  test('an unreachable server becomes a connection message', () async {
    final client = clientAnswering((request) async => throw const SocketException('Connection refused'));

    expect(
      client.get('alert-settings/care-recipient/1'),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', isNull)),
    );
  });
}
