import 'package:get_it/get_it.dart';
import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/application/communication_use_cases.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/application/location_use_cases.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/communication.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/mobility_repositories.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/domain/perimeter_monitor.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/infrastructure/remote/mobility_geofencing_api.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/infrastructure/repositories/mobility_repositories_impl.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/call/call_view_model.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/perimeter/perimeter_monitoring_view_model.dart';
import 'package:guardian_plus_app/features/mobility_geofencing/presentation/safe_zones/safe_zones_view_model.dart';

/// a call with no answer after this long is closed and logged.
const unansweredCallTimeout = Duration(seconds: 30);

/// How often the perimeter screen asks the platform for a new position.
const perimeterRefreshInterval = Duration(seconds: 15);

///consecutive readings outside every active zone before the exit alert is raised.
const perimeterSustainedReadings = 2;

/// Registers Mobility & Geofencing. Needs ApiClient and CareContextStore from the core.
void setupMobilityGeofencing(GetIt getIt) {
  // Infrastructure
  getIt.registerLazySingleton<MobilityGeofencingApi>(() => MobilityGeofencingApi(client: getIt<ApiClient>()));

  getIt.registerLazySingleton<LocationTrackingRepository>(
    () => LocationTrackingRepositoryImpl(api: getIt<MobilityGeofencingApi>()),
  );
  getIt.registerLazySingleton<SafeZoneRepository>(() => SafeZoneRepositoryImpl(api: getIt<MobilityGeofencingApi>()));
  getIt.registerLazySingleton<CommunicationRepository>(
    () => CommunicationRepositoryImpl(api: getIt<MobilityGeofencingApi>()),
  );

  // Application
  getIt.registerLazySingleton(() => GetCurrentLocationUseCase(repository: getIt<LocationTrackingRepository>()));
  getIt.registerLazySingleton(() => GetLocationHistoryUseCase(repository: getIt<LocationTrackingRepository>()));
  getIt.registerLazySingleton(() => GetMobilityStatusUseCase(repository: getIt<LocationTrackingRepository>()));
  getIt.registerLazySingleton(() => GetSafeZonesUseCase(repository: getIt<SafeZoneRepository>()));
  getIt.registerLazySingleton(() => SaveSafeZoneUseCase(repository: getIt<SafeZoneRepository>()));
  getIt.registerLazySingleton(() => DeleteSafeZoneUseCase(repository: getIt<SafeZoneRepository>()));
  getIt.registerLazySingleton(() => SetSafeZoneActiveUseCase(repository: getIt<SafeZoneRepository>()));

  getIt.registerLazySingleton(() => GetDeviceCapabilitiesUseCase(repository: getIt<CommunicationRepository>()));
  getIt.registerLazySingleton(
    () => StartCallUseCase(repository: getIt<CommunicationRepository>(), unansweredTimeout: unansweredCallTimeout),
  );
  getIt.registerLazySingleton(() => EndCallUseCase(repository: getIt<CommunicationRepository>()));
  getIt.registerLazySingleton(() => GetCallLogsUseCase(repository: getIt<CommunicationRepository>()));
  getIt.registerLazySingleton(() => SendHapticAlertUseCase(repository: getIt<CommunicationRepository>()));

  // Presentation: factories, the page disposes them
  getIt.registerFactory<SafeZonesViewModel>(
    () => SafeZonesViewModel(
      getSafeZones: getIt<GetSafeZonesUseCase>(),
      getCurrentLocation: getIt<GetCurrentLocationUseCase>(),
      saveSafeZone: getIt<SaveSafeZoneUseCase>(),
      deleteSafeZone: getIt<DeleteSafeZoneUseCase>(),
      setSafeZoneActive: getIt<SetSafeZoneActiveUseCase>(),
      careContextStore: getIt<CareContextStore>(),
    ),
  );

  getIt.registerFactory<PerimeterMonitoringViewModel>(
    () => PerimeterMonitoringViewModel(
      getCurrentLocation: getIt<GetCurrentLocationUseCase>(),
      getMobilityStatus: getIt<GetMobilityStatusUseCase>(),
      getSafeZones: getIt<GetSafeZonesUseCase>(),
      careContextStore: getIt<CareContextStore>(),
      refreshInterval: perimeterRefreshInterval,
      monitor: PerimeterMonitor(sustainedReadings: perimeterSustainedReadings),
    ),
  );

  // param1: the call type the caregiver asks for
  getIt.registerFactoryParam<CallViewModel, CallType, void>(
    (type, _) => CallViewModel(
      getDeviceCapabilities: getIt<GetDeviceCapabilitiesUseCase>(),
      startCall: getIt<StartCallUseCase>(),
      endCall: getIt<EndCallUseCase>(),
      getCallLogs: getIt<GetCallLogsUseCase>(),
      sendHapticAlert: getIt<SendHapticAlertUseCase>(),
      careContextStore: getIt<CareContextStore>(),
      now: DateTime.now,
      initialType: type,
    ),
  );
}
