import 'package:guardian_plus_app/core/session/care_context_store.dart';

/// Forgets whom the session cared for, so the next account starts clean. The app keeps no session token yet.
class LogoutUseCase {
  final CareContextStore careContextStore;

  const new({required this.careContextStore});

  void execute() {
    careContextStore.clear();
  }
}
