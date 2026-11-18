import 'dart:async';

import 'package:guardian_plus_app/features/auth/domain/authenticated_session.dart';
import 'package:guardian_plus_app/features/auth/domain/session_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesSessionRepository implements SessionRepository {
  static const _userAccountIdKey = 'guardian_session_user_account_id';

  static const _accessTokenKey = 'guardian_session_access_token';

  static const _expiresAtKey = 'guardian_session_expires_at';

  final SharedPreferences preferences;

  AuthenticatedSession? _current;

  SharedPreferencesSessionRepository({required this.preferences}) {
    _current = _read();

    if (_current?.isExpired() ?? false) {
      clear();
    }
  }

  @override
  AuthenticatedSession? currentSession() {
    final session = _current;

    if (session != null && session.isExpired()) {
      clear();
      return null;
    }

    return session;
  }

  @override
  void save(AuthenticatedSession session) {
    _current = session;

    unawaited(preferences.setString(_userAccountIdKey, session.userAccountId));

    unawaited(preferences.setString(_accessTokenKey, session.accessToken));

    unawaited(
      preferences.setInt(
        _expiresAtKey,
        session.expiresAt.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  void clear() {
    _current = null;

    unawaited(preferences.remove(_userAccountIdKey));

    unawaited(preferences.remove(_accessTokenKey));

    unawaited(preferences.remove(_expiresAtKey));
  }

  AuthenticatedSession? _read() {
    final userAccountId = preferences.getString(_userAccountIdKey);

    final accessToken = preferences.getString(_accessTokenKey);

    final expiresAtMillis = preferences.getInt(_expiresAtKey);

    if (userAccountId == null ||
        accessToken == null ||
        expiresAtMillis == null) {
      return null;
    }

    return AuthenticatedSession(
      userAccountId: userAccountId,
      accessToken: accessToken,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        expiresAtMillis,
        isUtc: true,
      ),
    );
  }
}
