import 'package:get_it/get_it.dart';
import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/features/profile/domain/profile_repository.dart';
import 'package:guardian_plus_app/features/profile/infrastructure/remote/profile_api.dart';
import 'package:guardian_plus_app/features/profile/infrastructure/repositories/profile_repository_impl.dart';

void setupProfile(GetIt getIt) {
  getIt.registerLazySingleton<ProfileApi>(
    () => ProfileApi(client: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(api: getIt<ProfileApi>()),
  );
}
