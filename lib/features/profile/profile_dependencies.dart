import 'package:get_it/get_it.dart';
import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/auth/domain/session_repository.dart';
import 'package:guardian_plus_app/features/profile/application/complete_onboarding_use_case.dart';
import 'package:guardian_plus_app/features/profile/application/load_care_context_use_case.dart';
import 'package:guardian_plus_app/features/profile/domain/profile_repository.dart';
import 'package:guardian_plus_app/features/profile/infrastructure/remote/profile_api.dart';
import 'package:guardian_plus_app/features/profile/infrastructure/repositories/profile_repository_impl.dart';
import 'package:guardian_plus_app/features/profile/presentation/onboarding/onboarding_viewmodel.dart';

void setupProfile(GetIt getIt) {
  getIt.registerLazySingleton<ProfileApi>(
    () => ProfileApi(client: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(api: getIt<ProfileApi>()),
  );

  getIt.registerLazySingleton<LoadCareContextUseCase>(
    () => LoadCareContextUseCase(
      sessionRepository: getIt<SessionRepository>(),
      profileRepository: getIt<ProfileRepository>(),
      careContextStore: getIt<CareContextStore>(),
    ),
  );

  getIt.registerLazySingleton<CompleteOnboardingUseCase>(
    () => CompleteOnboardingUseCase(
      profileRepository: getIt<ProfileRepository>(),
      loadCareContext: getIt<LoadCareContextUseCase>(),
    ),
  );

  getIt.registerFactory<OnboardingViewModel>(
    () => OnboardingViewModel(
      completeOnboarding: getIt<CompleteOnboardingUseCase>(),
    ),
  );
}
