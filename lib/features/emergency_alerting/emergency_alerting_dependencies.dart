import 'package:get_it/get_it.dart';
import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/core/time/server_clock.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/acknowledge_alert_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/add_emergency_contact_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/claim_alert_response_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/close_incident_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/complete_alert_response_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/configure_alert_channel_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_active_alerts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_by_id_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_channel_settings_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_history_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_alert_settings_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_emergency_contacts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_incident_by_alert_id_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/get_pending_alerts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/remove_emergency_contact_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/reorder_emergency_contacts_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/set_silent_mode_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/stabilize_incident_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/application/update_alert_settings_use_case.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_channel_setting_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_settings_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_api.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_channel_setting_api.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_settings_api.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/emergency_contact_api.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/incident_api.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/repositories/alert_channel_setting_repository_impl.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/repositories/alert_repository_impl.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/repositories/alert_settings_repository_impl.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/repositories/emergency_contact_repository_impl.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/repositories/incident_repository_impl.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/active_alerts/active_alerts_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/alert_detail_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_history/alert_history_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_settings/alert_settings_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/emergency_contacts/emergency_contacts_view_model.dart';

/// Registers Emergency & Alerting. It expects the core ones (ApiClient, CareContextStore) to be there,
/// so core/service_locator.dart calls it after _setupCore().
void setupEmergencyAlerting(GetIt getIt) {
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

  // Alerts and incidents
  getIt.registerLazySingleton<AlertApi>(() => AlertApi(client: getIt<ApiClient>()));

  getIt.registerLazySingleton<IncidentApi>(() => IncidentApi(client: getIt<ApiClient>()));

  getIt.registerLazySingleton<AlertRepository>(() => AlertRepositoryImpl(api: getIt<AlertApi>()));

  getIt.registerLazySingleton<IncidentRepository>(() => IncidentRepositoryImpl(api: getIt<IncidentApi>()));

  getIt.registerLazySingleton<GetActiveAlertsUseCase>(
    () => GetActiveAlertsUseCase(repository: getIt<AlertRepository>()),
  );

  getIt.registerLazySingleton<GetPendingAlertsUseCase>(
    () => GetPendingAlertsUseCase(repository: getIt<AlertRepository>()),
  );

  getIt.registerLazySingleton<GetAlertByIdUseCase>(() => GetAlertByIdUseCase(repository: getIt<AlertRepository>()));

  getIt.registerLazySingleton<GetAlertHistoryUseCase>(
    () => GetAlertHistoryUseCase(repository: getIt<AlertRepository>()),
  );

  getIt.registerLazySingleton<AcknowledgeAlertUseCase>(
    () => AcknowledgeAlertUseCase(repository: getIt<AlertRepository>()),
  );

  getIt.registerLazySingleton<ClaimAlertResponseUseCase>(
    () => ClaimAlertResponseUseCase(repository: getIt<AlertRepository>()),
  );

  getIt.registerLazySingleton<CompleteAlertResponseUseCase>(
    () => CompleteAlertResponseUseCase(repository: getIt<AlertRepository>()),
  );

  getIt.registerLazySingleton<GetIncidentByAlertIdUseCase>(
    () => GetIncidentByAlertIdUseCase(repository: getIt<IncidentRepository>()),
  );

  getIt.registerLazySingleton<StabilizeIncidentUseCase>(
    () => StabilizeIncidentUseCase(repository: getIt<IncidentRepository>()),
  );

  getIt.registerLazySingleton<CloseIncidentUseCase>(
    () => CloseIncidentUseCase(repository: getIt<IncidentRepository>()),
  );

  getIt.registerFactory<ActiveAlertsViewModel>(
    () => ActiveAlertsViewModel(
      getActiveAlerts: getIt<GetActiveAlertsUseCase>(),
      getPendingAlerts: getIt<GetPendingAlertsUseCase>(),
      getAlertById: getIt<GetAlertByIdUseCase>(),
      acknowledgeAlert: getIt<AcknowledgeAlertUseCase>(),
      getAlertSettings: getIt<GetAlertSettingsUseCase>(),
      getEmergencyContacts: getIt<GetEmergencyContactsUseCase>(),
      serverClock: getIt<ServerClock>(),
      careContextStore: getIt<CareContextStore>(),
    ),
  );

  getIt.registerFactory<AlertHistoryViewModel>(
    () => AlertHistoryViewModel(
      getAlertHistory: getIt<GetAlertHistoryUseCase>(),
      serverClock: getIt<ServerClock>(),
      careContextStore: getIt<CareContextStore>(),
    ),
  );

  // The detail needs the alert to show, so it is created with it: getIt<AlertDetailViewModel>(param1: alertId)
  getIt.registerFactoryParam<AlertDetailViewModel, String, void>(
    (alertId, _) => AlertDetailViewModel(
      alertId: alertId,
      getAlertById: getIt<GetAlertByIdUseCase>(),
      getIncidentByAlertId: getIt<GetIncidentByAlertIdUseCase>(),
      getEmergencyContacts: getIt<GetEmergencyContactsUseCase>(),
      getAlertSettings: getIt<GetAlertSettingsUseCase>(),
      acknowledgeAlert: getIt<AcknowledgeAlertUseCase>(),
      claimAlertResponse: getIt<ClaimAlertResponseUseCase>(),
      completeAlertResponse: getIt<CompleteAlertResponseUseCase>(),
      stabilizeIncident: getIt<StabilizeIncidentUseCase>(),
      closeIncident: getIt<CloseIncidentUseCase>(),
      serverClock: getIt<ServerClock>(),
      careContextStore: getIt<CareContextStore>(),
    ),
  );
}
