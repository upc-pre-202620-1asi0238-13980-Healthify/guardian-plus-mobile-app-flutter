import 'package:get_it/get_it.dart';
import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/add_emergency_contact_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/configure_alert_channel_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_channel_settings_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_settings_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_emergency_contacts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/remove_emergency_contact_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/reorder_emergency_contacts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/set_silent_mode_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/update_alert_settings_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_channel_setting_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_settings_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_channel_setting_api.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_settings_api.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/emergency_contact_api.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/repositories/alert_channel_setting_repository_impl.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/repositories/alert_settings_repository_impl.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/repositories/emergency_contact_repository_impl.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_settings/alert_settings_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/emergency_contacts/emergency_contacts_view_model.dart';
import 'package:http/http.dart' as http;

final getIt = GetIt.instance;

void setupDependencies() {
  _setupCore();
  _setupEmergencyAlerting();
}

void _setupCore() {
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  getIt.registerLazySingleton<ApiClient>(() => ApiClient(client: getIt<http.Client>()));

  getIt.registerLazySingleton<CareContextStore>(() => CareContextStore());
}

void _setupEmergencyAlerting() {
  // Infrastructure
  getIt.registerLazySingleton<EmergencyContactApi>(() => EmergencyContactApi(client: getIt<ApiClient>()));

  getIt.registerLazySingleton<AlertSettingsApi>(() => AlertSettingsApi(client: getIt<ApiClient>()));

  getIt.registerLazySingleton<AlertChannelSettingApi>(() => AlertChannelSettingApi(client: getIt<ApiClient>()));

  getIt.registerLazySingleton<EmergencyContactRepository>(
    () => EmergencyContactRepositoryImpl(api: getIt<EmergencyContactApi>()),
  );

  getIt.registerLazySingleton<AlertSettingsRepository>(
    () => AlertSettingsRepositoryImpl(api: getIt<AlertSettingsApi>()),
  );

  getIt.registerLazySingleton<AlertChannelSettingRepository>(
    () => AlertChannelSettingRepositoryImpl(api: getIt<AlertChannelSettingApi>()),
  );

  // Application
  getIt.registerLazySingleton<GetEmergencyContactsUseCase>(
    () => GetEmergencyContactsUseCase(repository: getIt<EmergencyContactRepository>()),
  );

  getIt.registerLazySingleton<AddEmergencyContactUseCase>(
    () => AddEmergencyContactUseCase(repository: getIt<EmergencyContactRepository>()),
  );

  getIt.registerLazySingleton<RemoveEmergencyContactUseCase>(
    () => RemoveEmergencyContactUseCase(repository: getIt<EmergencyContactRepository>()),
  );

  getIt.registerLazySingleton<ReorderEmergencyContactsUseCase>(
    () => ReorderEmergencyContactsUseCase(repository: getIt<EmergencyContactRepository>()),
  );

  getIt.registerLazySingleton<GetAlertSettingsUseCase>(
    () => GetAlertSettingsUseCase(repository: getIt<AlertSettingsRepository>()),
  );

  getIt.registerLazySingleton<UpdateAlertSettingsUseCase>(
    () => UpdateAlertSettingsUseCase(repository: getIt<AlertSettingsRepository>()),
  );

  getIt.registerLazySingleton<SetSilentModeUseCase>(
    () => SetSilentModeUseCase(repository: getIt<AlertSettingsRepository>()),
  );

  getIt.registerLazySingleton<GetAlertChannelSettingsUseCase>(
    () => GetAlertChannelSettingsUseCase(repository: getIt<AlertChannelSettingRepository>()),
  );

  getIt.registerLazySingleton<ConfigureAlertChannelUseCase>(
    () => ConfigureAlertChannelUseCase(repository: getIt<AlertChannelSettingRepository>()),
  );

  // Presentation: a factory, so every visit to a screen starts with fresh state and the page disposes it
  getIt.registerFactory<AlertSettingsViewModel>(
    () => AlertSettingsViewModel(
      getAlertSettings: getIt<GetAlertSettingsUseCase>(),
      updateAlertSettings: getIt<UpdateAlertSettingsUseCase>(),
      setSilentMode: getIt<SetSilentModeUseCase>(),
      getAlertChannelSettings: getIt<GetAlertChannelSettingsUseCase>(),
      configureAlertChannel: getIt<ConfigureAlertChannelUseCase>(),
      getEmergencyContacts: getIt<GetEmergencyContactsUseCase>(),
      careContextStore: getIt<CareContextStore>(),
    ),
  );

  getIt.registerFactory<EmergencyContactsViewModel>(
    () => EmergencyContactsViewModel(
      getEmergencyContacts: getIt<GetEmergencyContactsUseCase>(),
      getAlertSettings: getIt<GetAlertSettingsUseCase>(),
      addEmergencyContact: getIt<AddEmergencyContactUseCase>(),
      removeEmergencyContact: getIt<RemoveEmergencyContactUseCase>(),
      reorderEmergencyContacts: getIt<ReorderEmergencyContactsUseCase>(),
      careContextStore: getIt<CareContextStore>(),
    ),
  );
}
