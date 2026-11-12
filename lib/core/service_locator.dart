import 'package:get_it/get_it.dart';
import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/care_routines_wellness_dependencies.dart';
import 'package:guardian_plus_app/features/emergency_alerting/emergency_alerting_dependencies.dart';
import 'package:http/http.dart' as http;

final getIt = GetIt.instance;

/// Each bounded context registers its own dependencies in its own `*_dependencies.dart` file.
void setupDependencies() {
  _setupCore();
  setupEmergencyAlerting(getIt);
  setupCareRoutinesWellness(getIt);
}

void _setupCore() {
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  getIt.registerLazySingleton<ApiClient>(() => ApiClient(client: getIt<http.Client>()));

  getIt.registerLazySingleton<CareContextStore>(() => CareContextStore());
}
