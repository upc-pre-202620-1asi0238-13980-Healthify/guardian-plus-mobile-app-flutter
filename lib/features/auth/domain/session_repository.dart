import 'package:guardian_plus_app/features/auth/domain/authenticated_session.dart';

abstract interface class SessionRepository {
  AuthenticatedSession? currentSession();

  void save(AuthenticatedSession session);

  void clear();
}
