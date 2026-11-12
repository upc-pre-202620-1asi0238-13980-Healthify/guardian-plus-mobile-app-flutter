import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:http/http.dart' as http;

/// Platform's base URL. The default is the deployed API; a local backend is chosen at run time with
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1/` (Android emulator) or
/// `http://localhost:8080/api/v1/` (iOS simulator).
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://guardian-plus-api.chilecentral.cloudapp.azure.com/api/v1/',
);

/// Sends the requests of every feature's API to the platform and turns each failure into an [ApiException]
/// with a message the user understands, so the features only deal with the JSON of a successful answer.
class ApiClient {
  final http.Client client;
  final String baseUrl;

  const new({required this.client, this.baseUrl = apiBaseUrl});

  // The deployed API sleeps when idle, and its first answer takes a while
  static const _timeout = Duration(seconds: 30);

  Future<dynamic> get(String path) => _send('GET', path);

  Future<dynamic> post(String path, {Object? body}) => _send('POST', path, body: body);

  Future<dynamic> put(String path, {Object? body}) => _send('PUT', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(String method, String path, {Object? body}) async {
    final request = http.Request(method, Uri.parse('$baseUrl$path'))
      ..headers['Accept'] = 'application/json'
      // The platform localizes its error messages (messages_es.properties) from this header
      ..headers['Accept-Language'] = PlatformDispatcher.instance.locale.toLanguageTag();
    if (body != null) {
      request
        ..headers['Content-Type'] = 'application/json; charset=utf-8'
        ..body = jsonEncode(body);
    }

    final http.Response response;
    try {
      response = await http.Response.fromStream(await client.send(request).timeout(_timeout));
    } on SocketException {
      throw const ApiException('No se pudo conectar con el servidor. Revisa tu conexión.');
    } on http.ClientException {
      throw const ApiException('No se pudo conectar con el servidor. Revisa tu conexión.');
    } on TimeoutException {
      throw const ApiException('El servidor tardó demasiado en responder. Inténtalo de nuevo.');
    }

    // Decoded as UTF-8 explicitly: names and messages carry accents
    final text = utf8.decode(response.bodyBytes);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_errorMessage(text, response.statusCode), statusCode: response.statusCode);
    }
    if (text.isEmpty) {
      throw const ApiException('El servidor no devolvió datos');
    }
    return jsonDecode(text);
  }

  /// The platform's error body (ErrorResource) carries a localized message; it says why the action was rejected.
  String _errorMessage(String text, int statusCode) {
    try {
      final json = jsonDecode(text);
      if (json is Map<String, dynamic> && json['message'] is String) {
        return json['message'] as String;
      }
    } on FormatException {
      // Not JSON: fall through to the generic message
    }
    return 'El servidor respondió con el código $statusCode';
  }
}
