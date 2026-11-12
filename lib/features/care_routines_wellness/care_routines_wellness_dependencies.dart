import 'package:get_it/get_it.dart';
import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/cancel_reminder_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/configure_hydration_plan_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/configure_inactivity_detection_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/confirm_medication_acquisition_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/confirm_reminder_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_activity_log_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_activity_monitor_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_adherence_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_hydration_plan_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_medication_stocks_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_reminders_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_sleep_cycle_records_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/mark_reminder_as_missed_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/schedule_reminder_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_monitor_repository.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/adherence_repository.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/hydration_plan_repository.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/medication_stock_repository.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_repository.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/sleep_cycle_record_repository.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/activity_monitor_api.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/adherence_api.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/hydration_plan_api.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/medication_stock_api.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/reminder_api.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/sleep_cycle_record_api.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/repositories/activity_monitor_repository_impl.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/repositories/adherence_repository_impl.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/repositories/hydration_plan_repository_impl.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/repositories/medication_stock_repository_impl.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/repositories/reminder_repository_impl.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/repositories/sleep_cycle_record_repository_impl.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/activity/activity_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/appointment_form/appointment_form_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/appointments/appointments_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/hydration/hydration_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/inactivity/inactivity_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/medication/medication_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/medication_form/medication_form_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/routines/routines_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/sleep/sleep_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/stock/stock_view_model.dart';

/// Registers Care Routines & Wellness. It expects the core ones (ApiClient, CareContextStore) to be there,
/// so core/service_locator.dart calls it after _setupCore().
void setupCareRoutinesWellness(GetIt getIt) {
  // Infrastructure
  getIt.registerLazySingleton<ReminderApi>(() => ReminderApi(client: getIt<ApiClient>()));

  getIt.registerLazySingleton<AdherenceApi>(() => AdherenceApi(client: getIt<ApiClient>()));

  getIt.registerLazySingleton<HydrationPlanApi>(() => HydrationPlanApi(client: getIt<ApiClient>()));

  getIt.registerLazySingleton<MedicationStockApi>(() => MedicationStockApi(client: getIt<ApiClient>()));

  getIt.registerLazySingleton<ActivityMonitorApi>(() => ActivityMonitorApi(client: getIt<ApiClient>()));

  getIt.registerLazySingleton<SleepCycleRecordApi>(() => SleepCycleRecordApi(client: getIt<ApiClient>()));

  getIt.registerLazySingleton<ReminderRepository>(() => ReminderRepositoryImpl(api: getIt<ReminderApi>()));

  getIt.registerLazySingleton<AdherenceRepository>(() => AdherenceRepositoryImpl(api: getIt<AdherenceApi>()));

  getIt.registerLazySingleton<HydrationPlanRepository>(
    () => HydrationPlanRepositoryImpl(api: getIt<HydrationPlanApi>()),
  );

  getIt.registerLazySingleton<MedicationStockRepository>(
    () => MedicationStockRepositoryImpl(api: getIt<MedicationStockApi>()),
  );

  getIt.registerLazySingleton<ActivityMonitorRepository>(
    () => ActivityMonitorRepositoryImpl(api: getIt<ActivityMonitorApi>()),
  );

  getIt.registerLazySingleton<SleepCycleRecordRepository>(
    () => SleepCycleRecordRepositoryImpl(api: getIt<SleepCycleRecordApi>()),
  );

  // Application
  getIt.registerLazySingleton<GetRemindersUseCase>(() => GetRemindersUseCase(repository: getIt<ReminderRepository>()));

  getIt.registerLazySingleton<ScheduleReminderUseCase>(
    () => ScheduleReminderUseCase(repository: getIt<ReminderRepository>()),
  );

  getIt.registerLazySingleton<ConfirmReminderUseCase>(
    () => ConfirmReminderUseCase(repository: getIt<ReminderRepository>()),
  );

  getIt.registerLazySingleton<MarkReminderAsMissedUseCase>(
    () => MarkReminderAsMissedUseCase(repository: getIt<ReminderRepository>()),
  );

  getIt.registerLazySingleton<CancelReminderUseCase>(
    () => CancelReminderUseCase(repository: getIt<ReminderRepository>()),
  );

  getIt.registerLazySingleton<GetAdherenceUseCase>(() => GetAdherenceUseCase(repository: getIt<AdherenceRepository>()));

  getIt.registerLazySingleton<GetHydrationPlanUseCase>(
    () => GetHydrationPlanUseCase(repository: getIt<HydrationPlanRepository>()),
  );

  getIt.registerLazySingleton<ConfigureHydrationPlanUseCase>(
    () => ConfigureHydrationPlanUseCase(repository: getIt<HydrationPlanRepository>()),
  );

  getIt.registerLazySingleton<GetMedicationStocksUseCase>(
    () => GetMedicationStocksUseCase(repository: getIt<MedicationStockRepository>()),
  );

  getIt.registerLazySingleton<ConfirmMedicationAcquisitionUseCase>(
    () => ConfirmMedicationAcquisitionUseCase(repository: getIt<MedicationStockRepository>()),
  );

  getIt.registerLazySingleton<GetActivityMonitorUseCase>(
    () => GetActivityMonitorUseCase(repository: getIt<ActivityMonitorRepository>()),
  );

  getIt.registerLazySingleton<ConfigureInactivityDetectionUseCase>(
    () => ConfigureInactivityDetectionUseCase(repository: getIt<ActivityMonitorRepository>()),
  );

  getIt.registerLazySingleton<GetActivityLogUseCase>(
    () => GetActivityLogUseCase(repository: getIt<ActivityMonitorRepository>()),
  );

  getIt.registerLazySingleton<GetSleepCycleRecordsUseCase>(
    () => GetSleepCycleRecordsUseCase(repository: getIt<SleepCycleRecordRepository>()),
  );

  // Presentation: a factory, so every visit to a screen starts with fresh state and the page disposes it
  getIt.registerFactory<RoutinesViewModel>(
    () => RoutinesViewModel(
      getReminders: getIt<GetRemindersUseCase>(),
      getHydrationPlan: getIt<GetHydrationPlanUseCase>(),
      getSleepCycleRecords: getIt<GetSleepCycleRecordsUseCase>(),
      getActivityMonitor: getIt<GetActivityMonitorUseCase>(),
      getMedicationStocks: getIt<GetMedicationStocksUseCase>(),
      careContextStore: getIt<CareContextStore>(),
    ),
  );

  getIt.registerFactory<MedicationViewModel>(
    () => MedicationViewModel(
      getReminders: getIt<GetRemindersUseCase>(),
      getAdherence: getIt<GetAdherenceUseCase>(),
      confirmReminder: getIt<ConfirmReminderUseCase>(),
      markReminderAsMissed: getIt<MarkReminderAsMissedUseCase>(),
      careContextStore: getIt<CareContextStore>(),
    ),
  );

  getIt.registerFactory<MedicationFormViewModel>(
    () => MedicationFormViewModel(
      scheduleReminder: getIt<ScheduleReminderUseCase>(),
      careContextStore: getIt<CareContextStore>(),
    ),
  );

  getIt.registerFactory<AppointmentsViewModel>(
    () => AppointmentsViewModel(
      getReminders: getIt<GetRemindersUseCase>(),
      cancelReminder: getIt<CancelReminderUseCase>(),
      careContextStore: getIt<CareContextStore>(),
    ),
  );

  getIt.registerFactory<AppointmentFormViewModel>(
    () => AppointmentFormViewModel(
      scheduleReminder: getIt<ScheduleReminderUseCase>(),
      careContextStore: getIt<CareContextStore>(),
    ),
  );

  getIt.registerFactory<HydrationViewModel>(
    () => HydrationViewModel(
      getHydrationPlan: getIt<GetHydrationPlanUseCase>(),
      configureHydrationPlan: getIt<ConfigureHydrationPlanUseCase>(),
      careContextStore: getIt<CareContextStore>(),
    ),
  );

  getIt.registerFactory<ActivityViewModel>(
    () => ActivityViewModel(
      getReminders: getIt<GetRemindersUseCase>(),
      getAdherence: getIt<GetAdherenceUseCase>(),
      confirmReminder: getIt<ConfirmReminderUseCase>(),
      scheduleReminder: getIt<ScheduleReminderUseCase>(),
      careContextStore: getIt<CareContextStore>(),
    ),
  );

  getIt.registerFactory<InactivityViewModel>(
    () => InactivityViewModel(
      getActivityMonitor: getIt<GetActivityMonitorUseCase>(),
      getActivityLog: getIt<GetActivityLogUseCase>(),
      configureInactivityDetection: getIt<ConfigureInactivityDetectionUseCase>(),
      careContextStore: getIt<CareContextStore>(),
    ),
  );

  getIt.registerFactory<SleepViewModel>(
    () => SleepViewModel(
      getSleepCycleRecords: getIt<GetSleepCycleRecordsUseCase>(),
      careContextStore: getIt<CareContextStore>(),
    ),
  );

  getIt.registerFactory<StockViewModel>(
    () => StockViewModel(
      getMedicationStocks: getIt<GetMedicationStocksUseCase>(),
      confirmMedicationAcquisition: getIt<ConfirmMedicationAcquisitionUseCase>(),
      careContextStore: getIt<CareContextStore>(),
    ),
  );
}
