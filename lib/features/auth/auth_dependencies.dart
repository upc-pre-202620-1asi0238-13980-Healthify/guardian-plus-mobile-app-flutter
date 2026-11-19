import 'package:get_it/get_it.dart';
import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/auth/application/logout_use_case.dart';
import 'package:guardian_plus_app/features/auth/domain/auth_repository.dart';
import 'package:guardian_plus_app/features/auth/domain/session_repository.dart';
import 'package:guardian_plus_app/features/auth/infrastructure/local/shared_preferences_session_repository.dart';
import 'package:guardian_plus_app/features/auth/infrastructure/remote/auth_api.dart';
import 'package:guardian_plus_app/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Registers the IAM bounded context.
///
/// Core dependencies must already be registered.
void setupAuth(GetIt getIt, {required SharedPreferences preferences}) {
  // Session
  getIt.registerLazySingleton<SessionRepository>(
    () => SharedPreferencesSessionRepository(preferences: preferences),
  );

  // Infrastructure
  getIt.registerLazySingleton<AuthApi>(
    () => AuthApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(api: getIt<AuthApi>()),
  );

  // Application
  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(
      careContextStore: getIt<CareContextStore>(),
      sessionRepository: getIt<SessionRepository>(),
    ),
  );
}
