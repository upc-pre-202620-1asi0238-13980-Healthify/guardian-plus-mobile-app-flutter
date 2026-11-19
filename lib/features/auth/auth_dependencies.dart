import 'package:get_it/get_it.dart';
import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/auth/application/login_use_case.dart';
import 'package:guardian_plus_app/features/auth/application/logout_use_case.dart';
import 'package:guardian_plus_app/features/auth/application/resend_email_verification_use_case.dart';
import 'package:guardian_plus_app/features/auth/application/resend_otp_use_case.dart';
import 'package:guardian_plus_app/features/auth/application/verify_email_use_case.dart';
import 'package:guardian_plus_app/features/auth/application/verify_otp_use_case.dart';
import 'package:guardian_plus_app/features/auth/domain/auth_repository.dart';
import 'package:guardian_plus_app/features/auth/domain/session_repository.dart';
import 'package:guardian_plus_app/features/auth/infrastructure/local/shared_preferences_session_repository.dart';
import 'package:guardian_plus_app/features/auth/infrastructure/remote/auth_api.dart';
import 'package:guardian_plus_app/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:guardian_plus_app/features/auth/presentation/login_viewmodel.dart';
import 'package:guardian_plus_app/features/auth/presentation/otp/otp_verification_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void setupAuth(GetIt getIt, {required SharedPreferences preferences}) {
  getIt.registerLazySingleton<SessionRepository>(
    () => SharedPreferencesSessionRepository(preferences: preferences),
  );

  getIt.registerLazySingleton<AuthApi>(
    () => AuthApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(api: getIt<AuthApi>()),
  );

  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<VerifyOtpUseCase>(
    () => VerifyOtpUseCase(
      repository: getIt<AuthRepository>(),
      sessionRepository: getIt<SessionRepository>(),
    ),
  );

  getIt.registerLazySingleton<ResendOtpUseCase>(
    () => ResendOtpUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<VerifyEmailUseCase>(
    () => VerifyEmailUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<ResendEmailVerificationUseCase>(
    () => ResendEmailVerificationUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(
      careContextStore: getIt<CareContextStore>(),
      sessionRepository: getIt<SessionRepository>(),
    ),
  );

  getIt.registerFactory<LoginViewmodel>(
    () => LoginViewmodel(loginUseCase: getIt<LoginUseCase>()),
  );

  getIt.registerFactory<OtpVerificationViewModel>(
    () => OtpVerificationViewModel(
      verifyEmail: getIt<VerifyEmailUseCase>(),
      verifyOtp: getIt<VerifyOtpUseCase>(),
      resendEmailVerification: getIt<ResendEmailVerificationUseCase>(),
      resendOtp: getIt<ResendOtpUseCase>(),
    ),
  );
}
