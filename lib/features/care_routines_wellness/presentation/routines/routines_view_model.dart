import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/core/text/initials.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_activity_monitor_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_hydration_plan_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_medication_stocks_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_reminders_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/application/get_sleep_cycle_records_use_case.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_type.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_day.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_screen_states.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/routines/routines_state.dart';

/// Routines tab: today's progress, what comes next and a summary of every routine of Care Routines.
class RoutinesViewModel extends ChangeNotifier {
  final GetRemindersUseCase getReminders;
  final GetHydrationPlanUseCase getHydrationPlan;
  final GetSleepCycleRecordsUseCase getSleepCycleRecords;
  final GetActivityMonitorUseCase getActivityMonitor;
  final GetMedicationStocksUseCase getMedicationStocks;
  final CareContextStore careContextStore;

  new({
    required this.getReminders,
    required this.getHydrationPlan,
    required this.getSleepCycleRecords,
    required this.getActivityMonitor,
    required this.getMedicationStocks,
    required this.careContextStore,
  }) {
    load();
    // Reminders are issued and confirmed on the wristband, so the day is refreshed periodically
    _autoRefresh = Timer.periodic(_autoRefreshInterval, (_) {
      if (!_state.isLoading) _refresh();
    });
  }

  static const _autoRefreshInterval = Duration(seconds: 30);

  // Whose data this screen shows: the signed-in account and the person under its care
  late final CareContext _careContext = careContextStore.require();

  late RoutinesState _state = RoutinesState(careRecipientName: _careContext.careRecipientName, now: DateTime.now());
  RoutinesState get state => _state;

  String get userInitials => initialsOf(_careContext.userFullName);

  late final Timer _autoRefresh;
  bool _disposed = false;

  Future<void> load() async {
    _emit(_state.copyWith(isLoading: true, errorMessage: () => null));
    await _refresh();
  }

  /// Doses confirmed or plans changed on a routine screen show up as soon as the user is back.
  void onScreenShown() {
    if (_state.isLoaded && !_state.isLoading) _refresh();
  }

  Future<void> _refresh() async {
    final personUnderCareId = _careContext.careRecipientProfileId;
    final now = DateTime.now();
    final (startOfDay, startOfTomorrow) = todayBounds(now);

    // The sections are independent, so they are requested together instead of one after another
    final appointments = orNullOnError(
      getReminders.execute(personUnderCareId, from: now, type: ReminderType.appointment),
    );
    final hydrationPlan = orNullOnError(getHydrationPlan.execute(personUnderCareId));
    final sleepRecords = orNullOnError(getSleepCycleRecords.execute(personUnderCareId));
    final activityMonitor = orNullOnError(getActivityMonitor.execute(personUnderCareId));
    final medicationStocks = orNullOnError(getMedicationStocks.execute(personUnderCareId));

    // Without today's reminders there is no day to show; the other sections just stay empty
    try {
      final reminders = await getReminders.execute(personUnderCareId, from: startOfDay, to: startOfTomorrow);
      final nextAppointment = (await appointments)?.where((appointment) => appointment.status.isPending).firstOrNull;
      final plan = await hydrationPlan;
      final lastSleep = (await sleepRecords)?.firstOrNull;
      final monitor = await activityMonitor;
      final stocks = await medicationStocks ?? const [];
      _emit(_state.copyWith(
        isLoading: false,
        isLoaded: true,
        errorMessage: () => null,
        todayReminders: reminders,
        nextAppointment: () => nextAppointment,
        hydrationPlan: () => plan,
        lastSleep: () => lastSleep,
        activityMonitor: () => monitor,
        medicationStocks: stocks,
        now: DateTime.now(),
      ));
    } catch (e) {
      _emit(_state.copyWith(
        isLoading: false,
        errorMessage: () => routineErrorMessage(e, 'No se pudieron cargar las rutinas'),
      ));
    }
  }

  void _emit(RoutinesState state) {
    // A request can finish after the user has left the screen
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _autoRefresh.cancel();
    super.dispose();
  }
}
