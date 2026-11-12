import 'package:get_it/get_it.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/auth/application/logout_use_case.dart';

/// Registers IAM. It expects the core ones (CareContextStore) to be there, so core/service_locator.dart calls
/// it after _setupCore().
void setupAuth(GetIt getIt) {
  // Application
  getIt.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(careContextStore: getIt<CareContextStore>()));
}
