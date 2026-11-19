import 'package:get_it/get_it.dart';
import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/core/time/server_clock.dart';
import 'package:guardian_plus_app/features/auth/auth_dependencies.dart';
import 'package:guardian_plus_app/features/auth/domain/session_repository.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/care_routines_wellness_dependencies.dart';
import 'package:guardian_plus_app/features/emergency_alerting/emergency_alerting_dependencies.dart';
import 'package:guardian_plus_app/features/health_monitoring/health_monitoring_dependencies.dart';
import 'package:guardian_plus_app/features/profile/profile_dependencies.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

/// Each bounded context registers its own dependencies in its own
/// `*_dependencies.dart` file.
void setupDependencies({required SharedPreferences preferences}) {
  _setupCore();

  setupAuth(getIt, preferences: preferences);

  setupEmergencyAlerting(getIt);
  setupCareRoutinesWellness(getIt);
  setupHealthMonitoring(getIt);
  setupProfile(getIt);
}

void _setupCore() {
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  getIt.registerLazySingleton<ServerClock>(() => ServerClock());

  getIt.registerLazySingleton<CareContextStore>(() => CareContextStore());

  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      client: getIt<http.Client>(),
      serverClock: getIt<ServerClock>(),
      accessTokenProvider: () {
        if (!getIt.isRegistered<SessionRepository>()) {
          return null;
        }

        return getIt<SessionRepository>().currentSession()?.accessToken;
      },
    ),
  );
}
