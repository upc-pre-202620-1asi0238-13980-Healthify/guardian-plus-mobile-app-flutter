import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/auth/domain/session_repository.dart';

/// Clears the authenticated IAM session and the care context
/// associated with the account that is signing out.
class LogoutUseCase {
  final CareContextStore careContextStore;
  final SessionRepository sessionRepository;

  const LogoutUseCase({
    required this.careContextStore,
    required this.sessionRepository,
  });

  void execute() {
    careContextStore.clear();
    sessionRepository.clear();
  }
}
