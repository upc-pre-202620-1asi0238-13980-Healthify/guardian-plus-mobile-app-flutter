import 'package:get_it/get_it.dart';
import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/health_monitoring/application/get_live_vital_signs_use_case.dart';
import 'package:guardian_plus_app/features/health_monitoring/application/get_vital_sign_history_use_case.dart';
import 'package:guardian_plus_app/features/health_monitoring/application/get_wearable_devices_use_case.dart';
import 'package:guardian_plus_app/features/health_monitoring/application/link_wearable_device_use_case.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_repository.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/wearable_device_repository.dart';
import 'package:guardian_plus_app/features/health_monitoring/infrastructure/remote/vital_sign_api.dart';
import 'package:guardian_plus_app/features/health_monitoring/infrastructure/remote/wearable_device_api.dart';
import 'package:guardian_plus_app/features/health_monitoring/infrastructure/repositories/vital_sign_repository_impl.dart';
import 'package:guardian_plus_app/features/health_monitoring/infrastructure/repositories/wearable_device_repository_impl.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/live_vitals/live_vitals_view_model.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/vital_history/vital_history_view_model.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/wearable/link_wearable_view_model.dart';

/// Registers Health Monitoring. It expects the core ones (ApiClient, CareContextStore) to be there,
/// so core/service_locator.dart calls it after _setupCore().
void setupHealthMonitoring(GetIt getIt) {
  // Infrastructure
  getIt.registerLazySingleton<VitalSignApi>(() => VitalSignApi(client: getIt<ApiClient>()));

  getIt.registerLazySingleton<WearableDeviceApi>(() => WearableDeviceApi(client: getIt<ApiClient>()));

  getIt.registerLazySingleton<VitalSignRepository>(() => VitalSignRepositoryImpl(api: getIt<VitalSignApi>()));

  getIt.registerLazySingleton<WearableDeviceRepository>(
    () => WearableDeviceRepositoryImpl(api: getIt<WearableDeviceApi>()),
  );

  // Application
  getIt.registerLazySingleton<GetLiveVitalSignsUseCase>(
    () => GetLiveVitalSignsUseCase(repository: getIt<VitalSignRepository>()),
  );

  getIt.registerLazySingleton<GetVitalSignHistoryUseCase>(
    () => GetVitalSignHistoryUseCase(repository: getIt<VitalSignRepository>()),
  );

  getIt.registerLazySingleton<GetWearableDevicesUseCase>(
    () => GetWearableDevicesUseCase(repository: getIt<WearableDeviceRepository>()),
  );

  getIt.registerLazySingleton<LinkWearableDeviceUseCase>(
    () => LinkWearableDeviceUseCase(repository: getIt<WearableDeviceRepository>()),
  );

  // Presentation: a factory, so every visit to a screen starts with fresh state and the page disposes it
  getIt.registerFactory<LiveVitalsViewModel>(
    () => LiveVitalsViewModel(
      getLiveVitalSigns: getIt<GetLiveVitalSignsUseCase>(),
      getWearableDevices: getIt<GetWearableDevicesUseCase>(),
      getVitalSignHistory: getIt<GetVitalSignHistoryUseCase>(),
      careContextStore: getIt<CareContextStore>(),
    ),
  );

  getIt.registerFactory<VitalHistoryViewModel>(
    () => VitalHistoryViewModel(
      getVitalSignHistory: getIt<GetVitalSignHistoryUseCase>(),
      getLiveVitalSigns: getIt<GetLiveVitalSignsUseCase>(),
      careContextStore: getIt<CareContextStore>(),
    ),
  );

  getIt.registerFactory<LinkWearableViewModel>(
    () => LinkWearableViewModel(
      linkWearableDevice: getIt<LinkWearableDeviceUseCase>(),
      careContextStore: getIt<CareContextStore>(),
    ),
  );
}
