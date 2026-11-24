import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/core/time/server_clock.dart';
import 'package:http/http.dart' as http;

/// Platform's base URL. The default is the deployed API; a local backend is chosen at run time with
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1/` (Android emulator) or
/// `http://localhost:8080/api/v1/` (iOS simulator).
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue:
      'https://guardian-plus-api.chilecentral.cloudapp.azure.com/api/v1/',
);

/// Sends the requests of every feature's API to the platform and turns each failure into an [ApiException]
/// with a message the user understands, so the features only deal with the JSON of a successful answer.
class ApiClient {
  final http.Client client;
  final String baseUrl;
  final ServerClock? serverClock;

  /// Supplies the current IAM token without making Core depend directly
  /// on a concrete authentication implementation.
  final String? Function()? accessTokenProvider;

  /// Called when the platform rejects the current IAM token.
  final void Function()? onInvalidToken;

  const ApiClient({
    required this.client,
    this.baseUrl = apiBaseUrl,
    this.serverClock,
    this.accessTokenProvider,
    this.onInvalidToken,
  });

  static const _timeout = Duration(seconds: 30);

  Future<dynamic> get(String path, {bool authenticated = true}) {
    return _send('GET', path, authenticated: authenticated);
  }

  Future<dynamic> post(String path, {Object? body, bool authenticated = true}) {
    return _send('POST', path, body: body, authenticated: authenticated);
  }

  Future<dynamic> put(String path, {Object? body, bool authenticated = true}) {
    return _send('PUT', path, body: body, authenticated: authenticated);
  }

  Future<dynamic> patch(String path, {Object? body, bool authenticated = true}) {
    return _send('PATCH', path, body: body, authenticated: authenticated);
  }

  Future<dynamic> delete(String path, {bool authenticated = true}) {
    return _send('DELETE', path, authenticated: authenticated);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    required bool authenticated,
  }) async {
    final request = http.Request(method, Uri.parse('$baseUrl$path'))
      ..headers['Accept'] = 'application/json'
      ..headers['Accept-Language'] = PlatformDispatcher.instance.locale
          .toLanguageTag();

    if (authenticated) {
      final accessToken = accessTokenProvider?.call();

      if (accessToken != null && accessToken.trim().isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    if (body != null) {
      request
        ..headers['Content-Type'] = 'application/json; charset=utf-8'
        ..body = jsonEncode(body);
    }

    final http.Response response;

    try {
      response = await http.Response.fromStream(
        await client.send(request).timeout(_timeout),
      );
    } on SocketException {
      throw const ApiException(
        'No se pudo conectar con el servidor. Revisa tu conexión.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No se pudo conectar con el servidor. Revisa tu conexión.',
      );
    } on TimeoutException {
      throw const ApiException(
        'El servidor tardó demasiado en responder. Inténtalo de nuevo.',
      );
    }

    _syncClock(response.headers['date']);

    final text = utf8.decode(response.bodyBytes);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = _parseError(text, response.statusCode);

      if (authenticated && _isInvalidToken(response, error)) {
        onInvalidToken?.call();
      }

      throw ApiException(
        error.message,
        statusCode: response.statusCode,
        code: error.code,
        details: error.details,
      );
    }

    if (text.isEmpty) {
      // Deleting or toggling a resource may legitimately answer without a body
      if (response.statusCode == 204 || method == 'DELETE' || method == 'PATCH' || method == 'PUT') {
        return null;
      }
      throw const ApiException('El servidor no devolvió datos');
    }

    try {
      return jsonDecode(text);
    } on FormatException {
      // Some endpoints answer with a bare string (e.g. the id of a created resource)
      return text;
    }
  }

  bool _isInvalidToken(http.Response response, _ApiError error) {
    if (response.statusCode != 401) {
      return false;
    }

    final authenticateHeader =
        response.headers['www-authenticate']?.toLowerCase() ?? '';

    final errorCode = error.code?.toLowerCase() ?? '';

    return authenticateHeader.contains('invalid_token') ||
        errorCode == 'invalid_token';
  }

  void _syncClock(String? dateHeader) {
    if (serverClock == null || dateHeader == null) {
      return;
    }

    try {
      serverClock!.sync(HttpDate.parse(dateHeader));
    } on HttpException {
      // A malformed header only means the countdowns
      // keep the previous offset.
    }
  }

  _ApiError _parseError(String text, int statusCode) {
    try {
      final decoded = jsonDecode(text);

      if (decoded is Map<String, dynamic>) {
        return _ApiError(
          message: decoded['message'] is String
              ? decoded['message'] as String
              : 'El servidor respondió con el código $statusCode',
          code: decoded['code']?.toString(),
          details: decoded['details']?.toString(),
        );
      }
    } on FormatException {
      // Not JSON: fall through to the generic message.
    }

    return _ApiError(
      message: 'El servidor respondió con el código $statusCode',
    );
  }
}

class _ApiError {
  final String message;
  final String? code;
  final String? details;

  const _ApiError({required this.message, this.code, this.details});
}
